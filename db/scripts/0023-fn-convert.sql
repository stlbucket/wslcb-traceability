-- drop type lcb_fn.convert_inventory_source_input cascade;
-- drop type lcb_fn.convert_inventory_result_input cascade;

create type lcb_fn.convert_inventory_source_input as (
  id text,
  quantity numeric(10,2)
);

CREATE OR REPLACE FUNCTION lcb_fn.convert_inventory(
  _sources_info lcb_fn.convert_inventory_source_input[],
  _new_lots_info lcb_fn.report_inventory_lot_input[]
) 
RETURNS setof lcb.inventory_lot
    LANGUAGE plpgsql STRICT
    AS $$
  DECLARE
    _current_app_user auth.app_user;
    _lcb_license_holder_id text;
    _source_input lcb_fn.convert_inventory_source_input;
    _result_input lcb_fn.report_inventory_lot_input;
    _inventory_lot_id text;
    _result_lot lcb.inventory_lot;
    _parent_lot lcb.inventory_lot;
    _total_sourced_quantity numeric(10,2);
    _total_converted_quantity numeric(10,2);
    _conversion lcb.conversion;
    _conversion_source lcb.conversion_source;
    _source_inventory_type text;
    _result_inventory_type text;
  BEGIN
    _current_app_user := auth_fn.current_app_user();
    _total_sourced_quantity := 0;
    _total_converted_quantity := 0;

    -- this is not really correct.  need mechanism to switch between licenses
    select id
    into _lcb_license_holder_id
    from lcb.lcb_license_holder
    where app_tenant_id = _current_app_user.app_tenant_id;

    insert into lcb.conversion(app_tenant_id) 
    values (_current_app_user.app_tenant_id) 
    returning * into _conversion;

    foreach _source_input in ARRAY _sources_info
    loop
      select *
      into _parent_lot
      from lcb.inventory_lot
      where id = _source_input.id;

      if _parent_lot.id is null then
        raise exception 'illegal operation - batch cancelled:  no inventory lot exists for parent lot id: %', _source_input.id;
      end if;

      _source_inventory_type := coalesce(_source_inventory_type, _parent_lot.inventory_type);

      if _parent_lot.inventory_type != _source_inventory_type then
        raise exception 'illegal operation - batch cancelled:  all source lots must have same inventory type';
      end if;

      if _parent_lot.quantity < _source_input.quantity then
        raise exception 'illegal operation - batch cancelled:  source quantity (%) greater than parent lot quantity(%) parent lot id: %', _source_input.quantity, _parent_lot.quantity, _parent_lot.id;
      end if;

      _total_sourced_quantity := _total_sourced_quantity + _source_input.quantity;

      insert into lcb.conversion_source(app_tenant_id, conversion_id, inventory_lot_id, sourced_quantity)
      values (_current_app_user.app_tenant_id, _conversion.id, _parent_lot.id, _source_input.quantity);

      update lcb.inventory_lot set
        quantity = (quantity - _source_input.quantity)
      where id = _source_input.id
      returning * into _parent_lot;

      return next _parent_lot;

    end loop;


    foreach _result_input in ARRAY _new_lots_info
    loop

      if _result_input.quantity <= 0 then
        raise exception 'illegal operation - batch cancelled:  all conversions must have result quantity > 0';
      end if;

      -- make sure this lot can be identified later
      if _result_input.id is null or _result_input.id = '' then
        _inventory_lot_id := util_fn.generate_ulid();
      else
        -- _result_input.id should be verified as a valid ulid here
        _inventory_lot_id := _result_input.id;
      end if;
      
      -- find existing lot if it's there
      select *
      into _result_lot
      from lcb.inventory_lot
      where id = _inventory_lot_id;

      if _result_lot.id is not null then
        raise exception 'illegal operation - batch cancelled:  licensee specified inventory lot id already exists: %', _result_input.id;
      end if;

      insert into lcb.inventory_lot(
        id,
        updated_by_app_user_id,
        licensee_identifier,
        app_tenant_id,
        lcb_license_holder_id,
        id_origin,
        reporting_status,
        inventory_type,
        lot_type,
        description,
        quantity,
        strain_name,
        area_identifier,
        source_conversion_id
      )
      SELECT
        COALESCE(_result_input.id, util_fn.generate_ulid()),
        _current_app_user.id,
        _result_input.licensee_identifier,
        _current_app_user.app_tenant_id,
        _lcb_license_holder_id,
        case when _result_input.id is null then 'WSLCB' else 'LICENSEE' end,
        'ACTIVE',
        _result_input.inventory_type,
        'INVENTORY',
        _result_input.description::text,
        _result_input.quantity,
        _result_input.strain_name::text,
        _result_input.area_identifier::text,
        _conversion.id
      RETURNING * INTO _result_lot;

      _total_converted_quantity := _total_converted_quantity + _result_input.quantity;

      return next _result_lot;

    end loop;

    if _total_converted_quantity != _total_sourced_quantity then
      raise exception 'illegal operation - batch cancelled:  total converted quantity must equal total sourced quantity';
    end if;

    RETURN;


  end;
  $$;
