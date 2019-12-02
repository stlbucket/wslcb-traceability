drop function if exists auth_fn.current_app_user();

CREATE OR REPLACE FUNCTION auth_fn.current_app_user()
RETURNS auth.app_user
    LANGUAGE plpgsql STRICT
    AS $$
  DECLARE
    _app_user_id text;
    _app_user auth.app_user;
  BEGIN
    _app_user_id := current_setting('jwt.claims.app_user_id')::text;

    SELECT *
    INTO _app_user
    FROM auth.app_user
    WHERE id = _app_user_id
    ;

    return _app_user;
  end;
  $$;


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
    _created_count integer;
  BEGIN
    _created_count := 0;
    _current_app_user := auth_fn.current_app_user();

    -- this is not reall correct.  need mechanism to switch between licenses
    select id
    into _lcb_license_holder_id
    from lcb.lcb_license_holder
    where app_tenant_id = _current_app_user.app_tenant_id;

    -- raise exception '%, %', _current_app_user.app_tenant_id, _lcb_license_holder_id;

    RETURN QUERY INSERT INTO lcb.inventory_lot(
      app_tenant_id,
      lcb_license_holder_id,
      id_origin,
      inventory_type
    )
    SELECT
      _current_app_user.app_tenant_id,
      _lcb_license_holder_id,
      'WSLCB',
      _inventory_type
    FROM
      generate_series(1, _number_requested)
    RETURNING *
    ;
  end;
  $$;


-- create type lcb_fn.report_inventory_lot_input as (
--   id text,
--   inventory_type text,
--   description text,
--   quantity numeric(10,2),
--   units text,
--   strain_name text,
--   area_identifier text
-- );

-- CREATE OR REPLACE FUNCTION lcb_fn.report_inventory_lot(_report_inventory_lot_input lcb_fn.report_inventory_lot_input[]) 
-- RETURNS setof lcb.inventory_lot
--     LANGUAGE plpgsql STRICT
--     AS $$
--   DECLARE
--     _current_app_user auth.app_user;
--     _lcb_license_holder lcb.lcb_license_holder;
--   BEGIN
--     _current_app_user := auth_fn.current_app_user();

    

--     RETURN _app_tenant;
--   end;
--   $$;


