CREATE OR REPLACE FUNCTION lcb_fn.provision_inventory_lot_ids(
  _inventory_type text, 
  _number_requested integer
) 
RETURNS setof lcb.inventory_lot
    LANGUAGE plpgsql STRICT
    AS $$
  DECLARE
    _current_app_user auth.app_user;
    _lcb_license_holder_id text;
    _inventory_lot lcb.inventory_lot;
    _lcb_inventory_type lcb_ref.inventory_type;
    _lot_count integer;
  BEGIN
    _current_app_user := auth_fn.current_app_user();

    _lcb_license_holder_id := (select lcb_fn.get_currrent_lcb_license_holder_id());

    -- raise exception '%, %', _current_app_user.app_tenant_id, _lcb_license_holder_id;

    select *
    into _lcb_inventory_type
    from lcb_ref.inventory_type
    where id = _inventory_type
    ;

    if _lcb_inventory_type.id is null then
      raise exception 'illegal operation - batch cancelled:  no inventory type: %', _inventory_type;
    end if;

    if _lcb_inventory_type.is_single_lotted = false then
      RETURN QUERY INSERT INTO lcb.inventory_lot(
        updated_by_app_user_id,
        app_tenant_id,
        lcb_license_holder_id,
        id_origin,
        reporting_status,
        inventory_type,
        lot_type
      )
      SELECT
        _current_app_user.id,
        _current_app_user.app_tenant_id,
        _lcb_license_holder_id,
        'WSLCB',
        'PROVISIONED',
        _inventory_type,
        'INVENTORY'
      FROM
        generate_series(1, _number_requested)
      RETURNING *
      ;
    else
      _lot_count := 0;

      loop
        if _lot_count = _number_requested then 
          exit; 
        end if;

        INSERT INTO lcb.inventory_lot(
          updated_by_app_user_id,
          app_tenant_id,
          lcb_license_holder_id,
          id_origin,
          reporting_status,
          inventory_type,
          lot_type,
          quantity
        )
        SELECT
          _current_app_user.id,
          _current_app_user.app_tenant_id,
          _lcb_license_holder_id,
          'WSLCB',
          'PROVISIONED',
          _inventory_type,
          'INVENTORY',
          1
        RETURNING *
        INTO _inventory_lot
        ;
        _lot_count := _lot_count + 1;

        RETURN next _inventory_lot;
      end loop;

      RETURN;
    end if;

  end;
  $$;
