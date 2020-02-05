CREATE OR REPLACE FUNCTION lcb_fn.get_currrent_lcb_license_holder_id() 
RETURNS text
    LANGUAGE plpgsql STRICT
    AS $$
  DECLARE
    _current_app_user auth.app_user;
    _lcb_license_holder_id text;
  BEGIN
    _current_app_user := auth_fn.current_app_user();
    -- this is not really correct.  need mechanism to switch between licenses
    select id
    into _lcb_license_holder_id
    from lcb.lcb_license_holder
    where app_tenant_id = _current_app_user.app_tenant_id;

    RETURN _lcb_license_holder_id;
  end;
  $$;
