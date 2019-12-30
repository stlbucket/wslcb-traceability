-- drop type lcb_fn.convert_inventory_source_input cascade;
-- drop type lcb_fn.convert_inventory_result_input cascade;

create type lcb_fn.convert_inventory_source_input as (
  id text,
  quantity numeric(10,2)
);

create type lcb_fn.convert_inventory_result_input as (
  id text,
  licensee_identifier text,
  inventory_type text,
  description text,
  quantity numeric(10,2),
  area_name text
);

CREATE OR REPLACE FUNCTION lcb_fn.convert_inventory(
  _to_inventory_type_id text,
  _sources_info lcb_fn.convert_inventory_source_input[],
  _new_lots_info lcb_fn.convert_inventory_result_input[]
) 
RETURNS setof lcb.inventory_lot
    LANGUAGE plpgsql STRICT
    AS $$
  DECLARE
    _current_app_user auth.app_user;
    _lcb_license_holder_id text;
    _source_input lcb_fn.convert_inventory_source_input;
    _result_input lcb_fn.convert_inventory_result_input;
    _inventory_lot_id text;
    _to_inventory_type lcb_ref.inventory_type;
    _result_lot lcb.inventory_lot;
    _parent_lot lcb.inventory_lot;
    _total_sourced_quantity numeric(10,2);
    _current_sourced_quantity numeric(10,2);
    _total_converted_quantity numeric(10,2);
    _conversion lcb.conversion;
    _conversion_source lcb.conversion_source;
    _source_inventory_type text;
    _result_inventory_type text;
    _conversion_rule lcb_ref.conversion_rule;
    _conversion_source_allowed boolean;
    _result_strain_id text;
    _result_area_id text;
    _lot_count integer;
  BEGIN
    _current_app_user := auth_fn.current_app_user();
    _total_sourced_quantity := 0;
    _total_converted_quantity := 0;

    -- get the conversion rule
    select *
    into _conversion_rule
    from lcb_ref.conversion_rule
    where to_inventory_type_id = _to_inventory_type_id
    ;

    if _conversion_rule.to_inventory_type_id is null then
        raise exception 'illegal operation - batch cancelled:  no conversion rule for inventory type id: %', _to_inventory_type_id;
    end if;

    -- get the inventory type we are converting to
    select *
    into _to_inventory_type
    from lcb_ref.inventory_type
    where id = _to_inventory_type_id
    ;

    if _to_inventory_type.id is null then
        raise exception 'illegal operation - batch cancelled:  no inventory type for id: %', _to_inventory_type_id;
    end if;

    -- this is not really correct.  need mechanism to switch between licenses
    select id
    into _lcb_license_holder_id
    from lcb.lcb_license_holder
    where app_tenant_id = _current_app_user.app_tenant_id;

    -- create the base record for this conversion
    insert into lcb.conversion(app_tenant_id, conversion_rule_to_inventory_type_id) 
    values (_current_app_user.app_tenant_id, _to_inventory_type_id)
    returning * into _conversion;

    -- loop through all source inventory lots
    foreach _source_input in ARRAY _sources_info
    loop
      -- find the parent lot
      select *
      into _parent_lot
      from lcb.inventory_lot
      where id = _source_input.id;

      if _parent_lot.id is null then
        raise exception 'illegal operation - batch cancelled:  no inventory lot exists for parent lot id: %', _source_input.id;
      end if;

      -- the strain_id for all resultant lots.   all source inputs must have the same value here or we throw an exception
      _result_strain_id := coalesce(_result_strain_id, _parent_lot.strain_id);

      if _result_strain_id != _parent_lot.strain_id then
        if _to_inventory_type.is_strain_mixable = true then
          insert into lcb.strain(app_tenant_id, lcb_license_holder_id, name)
          values (_current_app_user.app_tenant_id, _lcb_license_holder_id, 'Mixed')
          on conflict(lcb_license_holder_id, name)
          do update set lcb_license_holder = _lcb_license_holder_id
          returning id into _result_strain_id
          ;
        else
          raise exception 'illegal operation - batch cancelled:  all source strains must be the same for inventory type: %', _to_inventory_type.id;
        end if;
      end if;

      -- make sure this inventory type can be used as a conversion source for the intended target
      select (count(*) > 0)
      into _conversion_source_allowed
      from lcb_ref.conversion_rule_source
      where to_inventory_type_id = _to_inventory_type_id
      and inventory_type_id = _parent_lot.inventory_type
      ;

      if _conversion_source_allowed = false then
        raise exception 'illegal operation - batch cancelled:  inventory type: %  cannot be converted to inventory type: %', _parent_lot.inventory_type, _to_inventory_type_id;
      end if;

      -- the strain_id for all resultant lots.   all source inputs must have the same value here or we throw an exception
      _source_inventory_type := coalesce(_source_inventory_type, _parent_lot.inventory_type);

      if _parent_lot.inventory_type != _source_inventory_type then
        raise exception 'illegal operation - batch cancelled:  all source lots must have same inventory type';
      end if;

      _current_sourced_quantity := 0;
      if _conversion_rule.is_non_destructive = false then
        _current_sourced_quantity := _source_input.quantity;
        -- make sure the parent lot has enough quantity to source
        if _parent_lot.quantity < _current_sourced_quantity then
          raise exception 'illegal operation - batch cancelled:  source quantity (%) greater than parent lot quantity(%) parent lot id: %', _current_sourced_quantity, _parent_lot.quantity, _parent_lot.id;
        end if;

        -- remove sourced quantity from parent
        update lcb.inventory_lot set
          quantity = (quantity - _current_sourced_quantity),
          reporting_status = case when (quantity - _current_sourced_quantity) > 0 then 'ACTIVE' else 'DEPLETED' end
        where id = _source_input.id
        returning * into _parent_lot;

        -- add to the running sourced total
        _total_sourced_quantity := _total_sourced_quantity + _current_sourced_quantity;
      end if;

      insert into lcb.conversion_source(app_tenant_id, conversion_id, inventory_lot_id, sourced_quantity)
      values (_current_app_user.app_tenant_id, _conversion.id, _parent_lot.id, _current_sourced_quantity);

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

      if _result_input.area_name is null or _result_input.area_name::text = '' then
        raise exception 'illegal operation - batch cancelled:  all result lots must specify area name';
      end if;

      insert into lcb.area(
        app_tenant_id,
        lcb_license_holder_id,
        name
      )
      values (
        _current_app_user.app_tenant_id,
        _lcb_license_holder_id,
        _result_input.area_name::text
      )
      on conflict(lcb_license_holder_id, name)
      do update set lcb_license_holder_id = _lcb_license_holder_id
      returning id into _result_area_id
      ;

      if _to_inventory_type.is_single_lotted = false then
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
          strain_id,
          area_id,
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
          _result_strain_id,
          _result_area_id,
          _conversion.id
        RETURNING * INTO _result_lot;

        _total_converted_quantity := _total_converted_quantity + _result_input.quantity;

        return next _result_lot;
      else
        _lot_count := 0;

        loop
          if _lot_count = _result_input.quantity then 
            exit; 
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
            strain_id,
            area_id,
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
            1,
            _result_strain_id,
            _result_area_id,
            _conversion.id
          RETURNING * INTO _result_lot;

          _total_converted_quantity := _total_converted_quantity + 1;
          _lot_count := _lot_count + 1;

          return next _result_lot;
        end loop;
      end if;
    end loop;

    if _total_converted_quantity != _total_sourced_quantity AND _conversion_rule.is_zero_sum = true then
      raise exception 'illegal operation - batch cancelled:  total converted quantity (%) must equal total sourced quantity (%).', _total_converted_quantity, _total_sourced_quantity;
    end if;

    RETURN;


  end;
  $$;
