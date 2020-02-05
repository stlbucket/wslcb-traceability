CREATE OR REPLACE FUNCTION lcb_fn.invalidate_inventory_lot_ids(_ids text[]) 
RETURNS setof lcb.inventory_lot
    LANGUAGE plpgsql STRICT
    AS $$
  DECLARE
    _current_app_user auth.app_user;
    _lcb_license_holder_id text;
    _inventory_lot lcb.inventory_lot;
    _inventory_lot_id text;
  BEGIN
    _current_app_user := auth_fn.current_app_user();

    -- only provisioned ids can be invalidated
    if 0 < (select count(*) from lcb.inventory_lot where id = ANY(_ids) and reporting_status != 'PROVISIONED') then
      raise exception 'illegal operation - batch cancelled: only provisioned ids can be invalidated.';
    end if;

    update lcb.inventory_lot set
      reporting_status = 'INVALIDATED'
    where id = ANY(_ids);

    RETURN QUERY SELECT * FROM lcb.inventory_lot WHERE id = ANY(_ids);
  END;
  $$;
