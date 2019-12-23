CREATE OR REPLACE FUNCTION lcb_fn.app_tenant_manifest_ids() RETURNS setof text
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $$
  DECLARE
    _current_app_user auth.app_user;
    _lcb_license_holder_id text;
    _retval boolean;
  BEGIN
    _current_app_user := auth_fn.current_app_user();

    -- this is not really correct.  need mechanism to switch between licenses
    select id
    into _lcb_license_holder_id
    from lcb.lcb_license_holder
    where app_tenant_id = _current_app_user.app_tenant_id;

    RETURN QUERY
    select m.id
    from lcb.manifest m
    where from_lcb_license_holder_id = _lcb_license_holder_id
    or to_lcb_license_holder_id = _lcb_license_holder_id
    ;
  end;
  $$;

