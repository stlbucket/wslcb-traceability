CREATE OR REPLACE FUNCTION lcb_fn_axs.wtf()
returns boolean
    LANGUAGE plpgsql STRICT
    AS $$
BEGIN
  return false;
end;
$$;
  
CREATE OR REPLACE FUNCTION lcb_fn_axs.insert_inventory_lot(
  _id text,
  _app_tenant_id text,
  _lcb_license_holder_id text,
  _inventory_type text,
  _reporting_status text,
  _id_origin text,
  _area_id text,
  _strain_id text,
  _updated_by_app_user_id text,
  _lot_type text,
  _quantity numeric,
  _description text,
  _licensee_identifier text,
  _source_conversion_id text,
  _retval jsonb
) 
RETURNS jsonb
    LANGUAGE plpgsql STRICT volatile
    AS $$
  DECLARE
    _inventory_lot lcb.inventory_lot;
  BEGIN
    _retval := '{}';
    -- _id needs to be validated as a ulid
raise exception 'omg';

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
      _id,
      _updated_by_app_user_id,
      _licensee_identifier,
      _app_tenant_id,
      _lcb_license_holder_id,
      _id_origin,
      _reporting_status,
      _inventory_type,
      _lot_type,
      _description,
      _quantity,
      _strain_id,
      _area_id,
      _source_conversion_id
    RETURNING * 
    INTO _inventory_lot
    ;

    _retval := to_jsonb(_inventory_lot);

    RETURN _retval;
  end;
  $$;
