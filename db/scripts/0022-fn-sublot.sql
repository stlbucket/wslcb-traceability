create type lcb_fn.sublot_inventory_input as (
  id text,
  licensee_identifier text,
  quantity numeric(10,2)
);

CREATE OR REPLACE FUNCTION lcb_fn.sublot_inventory(
  _parent_lot_id text, 
  _sublots_info lcb_fn.sublot_inventory_input[]
) 
RETURNS setof lcb.inventory_lot
    LANGUAGE plpgsql STRICT
    AS $$
  DECLARE
    _current_app_user auth.app_user;
    _lcb_license_holder_id text;
    _sublot_inventory_input lcb_fn.sublot_inventory_input;
    _inventory_lot_id text;
    _sublot lcb.inventory_lot;
    _parent_lot lcb.inventory_lot;
    _total_sublotted_quantity numeric(10,2);
    _conversion lcb.conversion;
    _conversion_source lcb.conversion_source;
  BEGIN
    _current_app_user := auth_fn.current_app_user();
    _total_sublotted_quantity := 0;

    -- this is not really correct.  need mechanism to switch between licenses
    select id
    into _lcb_license_holder_id
    from lcb.lcb_license_holder
    where app_tenant_id = _current_app_user.app_tenant_id;

    select *
    into _parent_lot
    from lcb.inventory_lot
    where id = _parent_lot_id;

    if _parent_lot.id is null then
      raise exception 'illegal operation - batch cancelled:  no inventory lot exists for _parent_lot_id: %', _parent_lot_id;
    end if;

    foreach _sublot_inventory_input in ARRAY _sublots_info
    loop

      if _sublot_inventory_input.quantity <= 0 then
        raise exception 'illegal operation - batch cancelled:  all sublots must have quantity > 0';
      end if;

      -- make sure this lot can be identified later
      if _sublot_inventory_input.id is null or _sublot_inventory_input.id = '' then
        _inventory_lot_id := util_fn.generate_ulid();
      else
        -- _sublot_inventory_input.id should be verified as a valid ulid here
        _inventory_lot_id := _sublot_inventory_input.id;
      end if;
      
      -- find existing lot if it's there
      select *
      into _sublot
      from lcb.inventory_lot
      where id = _inventory_lot_id;

      if _sublot.id is null then
        insert into lcb.conversion(app_tenant_id) 
        values (_current_app_user.app_tenant_id) 
        returning * into _conversion;

        insert into lcb.conversion_source(app_tenant_id, conversion_id, inventory_lot_id, sourced_quantity)
        values (_current_app_user.app_tenant_id, _conversion.id, _parent_lot_id, _sublot_inventory_input.quantity);

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
          COALESCE(_sublot_inventory_input.id, util_fn.generate_ulid()),
          _current_app_user.id,
          _sublot_inventory_input.licensee_identifier,
          _current_app_user.app_tenant_id,
          _lcb_license_holder_id,
          case when _sublot_inventory_input.id is null then 'WSLCB' else 'LICENSEE' end,
          'ACTIVE',
          _parent_lot.inventory_type,
          'INVENTORY',
          _parent_lot.description::text,
          _sublot_inventory_input.quantity,
          _parent_lot.strain_name::text,
          _parent_lot.area_identifier::text,
          _conversion.id
        RETURNING * INTO _sublot;

        _total_sublotted_quantity := _total_sublotted_quantity + _sublot_inventory_input.quantity;

        if _total_sublotted_quantity > _parent_lot.quantity then
          raise exception 'illegal operation - batch cancelled:  total sublotted quantity exceeds parent lot quantity';
        end if;

      else
        raise exception 'illegal operation - batch cancelled:  licensee specified sublot id already exists: %', _sublot.id;
      end if;

      return next _sublot;

    end loop;

    update lcb.inventory_lot set
      quantity = (quantity - _total_sublotted_quantity)
    where id = _parent_lot_id
    returning * into _parent_lot;

    return next _parent_lot;

    RETURN;


  end;
  $$;
