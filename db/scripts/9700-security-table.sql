

DO
$body$
  DECLARE 
    _pol pg_policies;
    _drop_sql text;
  BEGIN

    for _pol in
      select 
        *
      from pg_policies
    loop
      _drop_sql := 'drop policy if exists ' || _pol.policyname || ' on ' || _pol.schemaname || '.' || _pol.tablename || ';';
      -- raise notice 'pol: %', _pol.policyname;
      -- raise notice '_drop_sql: %', _drop_sql;
      execute _drop_sql;
    end loop
    ;
  END
$body$;


----------
----------  BEGIN TABLE POLICY: app.application
----------  POLICY NAME:  app_user  select only no rls  :::  app_super_admin manage
----------

----------  REMOVE EXISTING TABLE GRANTS

  revoke all privileges 
  on table app.application 
  from public;

  revoke all privileges 
  on table app.application 
  from app_super_admin, app_tenant_admin, app_admin, app_demon, app_user, app_anonymous;

----------  DISABLE ROW LEVEL SECURITY

  alter table app.application disable row level security;

----------  CREATE NEW TABLE GRANTS

----------  app_super_admin
  grant 
    insert, -- ( id, created_at, updated_at, external_id, name, key ), 
        -- no excluded columns
    update, -- ( id, created_at, updated_at, external_id, name, key ),
        -- no excluded columns
    delete  
  on table app.application 
  to app_super_admin;


----------  app_user
  grant 
    select  
  on table app.application 
  to app_user;



----------  END TABLE POLICY: app.application
--==
----------
----------  BEGIN TABLE POLICY: app.license
----------  POLICY NAME:  app_user default with rls
----------

----------  REMOVE EXISTING TABLE GRANTS

  revoke all privileges 
  on table app.license 
  from public;

  revoke all privileges 
  on table app.license 
  from app_super_admin, app_tenant_admin, app_admin, app_demon, app_user, app_anonymous;

----------  ENABLE ROW LEVEL SECURITY

  alter table app.license enable row level security;

  create policy rls_app_user_default_app_license 
    on app.license
    as permissive
    for all
    to app_user
    using ( auth_fn.app_user_has_access(app_tenant_id) = true )
    ;


----------  CREATE NEW TABLE GRANTS

----------  app_user
  grant 
    select , 
    insert, -- ( id, app_tenant_id, created_at, updated_at, external_id, name, license_type_id, assigned_to_app_user_id ), 
        -- no excluded columns
    update, -- ( id, app_tenant_id, created_at, updated_at, external_id, name, license_type_id, assigned_to_app_user_id ), 
        -- no excluded columns
    delete  
  on table app.license 
  to app_user;



----------  END TABLE POLICY: app.license
--==
----------
----------  BEGIN TABLE POLICY: app.license_permission
----------  POLICY NAME:  Custom Policy: app.license_permission
----------

----------  REMOVE EXISTING TABLE GRANTS

  revoke all privileges 
  on table app.license_permission 
  from public;

  revoke all privileges 
  on table app.license_permission 
  from app_super_admin, app_tenant_admin, app_admin, app_demon, app_user, app_anonymous;

----------  ENABLE ROW LEVEL SECURITY

  alter table app.license_permission enable row level security;

  create policy rls_app_user_default_app_license_permission 
    on app.license_permission
    as permissive
    for all
    to app_user
    using ( auth_fn.app_user_has_access(app_tenant_id) = true )
    ;


----------  CREATE NEW TABLE GRANTS

----------  app_admin
  grant 
    insert, -- ( id, app_tenant_id, created_at, updated_at, license_id, permission_id ), 
        -- no excluded columns
    update, -- ( id, app_tenant_id, created_at, updated_at, license_id, permission_id ),
        -- no excluded columns
    delete  
  on table app.license_permission 
  to app_admin;


----------  app_user
  grant 
    select  
  on table app.license_permission 
  to app_user;



----------  END TABLE POLICY: app.license_permission
--==
----------
----------  BEGIN TABLE POLICY: app.license_type
----------  POLICY NAME:  app_user  select only no rls  :::  app_super_admin manage
----------

----------  REMOVE EXISTING TABLE GRANTS

  revoke all privileges 
  on table app.license_type 
  from public;

  revoke all privileges 
  on table app.license_type 
  from app_super_admin, app_tenant_admin, app_admin, app_demon, app_user, app_anonymous;

----------  DISABLE ROW LEVEL SECURITY

  alter table app.license_type disable row level security;

----------  CREATE NEW TABLE GRANTS

----------  app_super_admin
  grant 
    insert, -- ( id, created_at, updated_at, external_id, name, key, application_id ), 
        -- no excluded columns
    update, -- ( id, created_at, updated_at, external_id, name, key, application_id ),
        -- no excluded columns
    delete  
  on table app.license_type 
  to app_super_admin;


----------  app_user
  grant 
    select  
  on table app.license_type 
  to app_user;



----------  END TABLE POLICY: app.license_type
--==
----------
----------  BEGIN TABLE POLICY: app.license_type_permission
----------  POLICY NAME:  app_user  select only no rls  :::  app_super_admin manage
----------

----------  REMOVE EXISTING TABLE GRANTS

  revoke all privileges 
  on table app.license_type_permission 
  from public;

  revoke all privileges 
  on table app.license_type_permission 
  from app_super_admin, app_tenant_admin, app_admin, app_demon, app_user, app_anonymous;

----------  DISABLE ROW LEVEL SECURITY

  alter table app.license_type_permission disable row level security;

----------  CREATE NEW TABLE GRANTS

----------  app_super_admin
  grant 
    insert, -- ( id, created_at, updated_at, license_type_id, permission_id, key ), 
        -- no excluded columns
    update, -- ( id, created_at, updated_at, license_type_id, permission_id, key ),
        -- no excluded columns
    delete  
  on table app.license_type_permission 
  to app_super_admin;


----------  app_user
  grant 
    select  
  on table app.license_type_permission 
  to app_user;



----------  END TABLE POLICY: app.license_type_permission
--==
----------
----------  BEGIN TABLE POLICY: auth.config_auth
----------  POLICY NAME:  Default Table Policy - NO ACCESS
----------

----------  REMOVE EXISTING TABLE GRANTS

  revoke all privileges 
  on table auth.config_auth 
  from public;

  revoke all privileges 
  on table auth.config_auth 
  from app_super_admin, app_tenant_admin, app_admin, app_demon, app_user, app_anonymous;

----------  DISABLE ROW LEVEL SECURITY

  alter table auth.config_auth disable row level security;

----------  CREATE NEW TABLE GRANTS


----------  END TABLE POLICY: auth.config_auth
--==
----------
----------  BEGIN TABLE POLICY: auth.permission
----------  POLICY NAME:  app_user  select only no rls  :::  app_super_admin manage
----------

----------  REMOVE EXISTING TABLE GRANTS

  revoke all privileges 
  on table auth.permission 
  from public;

  revoke all privileges 
  on table auth.permission 
  from app_super_admin, app_tenant_admin, app_admin, app_demon, app_user, app_anonymous;

----------  DISABLE ROW LEVEL SECURITY

  alter table auth.permission disable row level security;

----------  CREATE NEW TABLE GRANTS

----------  app_super_admin
  grant 
    insert, -- ( id, created_at, key ), 
        -- no excluded columns
    update, -- ( id, created_at, key ),
        -- no excluded columns
    delete  
  on table auth.permission 
  to app_super_admin;


----------  app_user
  grant 
    select  
  on table auth.permission 
  to app_user;



----------  END TABLE POLICY: auth.permission
--==
----------
----------  BEGIN TABLE POLICY: auth.app_tenant
----------  POLICY NAME:  Custom Policy: auth.app_tenant
----------

----------  REMOVE EXISTING TABLE GRANTS

  revoke all privileges 
  on table auth.app_tenant 
  from public;

  revoke all privileges 
  on table auth.app_tenant 
  from app_super_admin, app_tenant_admin, app_admin, app_demon, app_user, app_anonymous;

----------  ENABLE ROW LEVEL SECURITY

  alter table auth.app_tenant enable row level security;

  create policy rls_auth_app_tenant_auth_app_tenant 
    on auth.app_tenant
    as permissive
    for all
    to app_user
    using ( auth_fn.app_user_has_access(id) = true )
    ;


----------  CREATE NEW TABLE GRANTS

----------  app_super_admin
  grant 
    insert, -- ( id, created_at, updated_at, name, identifier ), 
        -- no excluded columns
    update, -- ( id, created_at, updated_at, name, identifier ),
        -- no excluded columns
    delete  
  on table auth.app_tenant 
  to app_super_admin;


----------  app_user
  grant 
    select  
  on table auth.app_tenant 
  to app_user;



----------  END TABLE POLICY: auth.app_tenant
--==
----------
----------  BEGIN TABLE POLICY: auth.app_user
----------  POLICY NAME:  Custom Policy: auth.app_user
----------

----------  REMOVE EXISTING TABLE GRANTS

  revoke all privileges 
  on table auth.app_user 
  from public;

  revoke all privileges 
  on table auth.app_user 
  from app_super_admin, app_tenant_admin, app_admin, app_demon, app_user, app_anonymous;

----------  ENABLE ROW LEVEL SECURITY

  alter table auth.app_user enable row level security;

  create policy rls_app_user_default_auth_app_user 
    on auth.app_user
    as permissive
    for all
    to app_user
    using ( auth_fn.app_user_has_access(app_tenant_id) = true )
    ;


----------  CREATE NEW TABLE GRANTS

----------  app_admin
  grant 
    insert, -- ( id, app_tenant_id, created_at, updated_at, username, recovery_email, password_hash, inactive, password_reset_required, permission_key ),
        -- no excluded columns
    delete  
  on table auth.app_user 
  to app_admin;


----------  app_user
  grant 
    select , 
    update -- ( id, app_tenant_id, created_at, updated_at, username, recovery_email, password_hash, inactive, password_reset_required, permission_key )
        -- no excluded columns
  on table auth.app_user 
  to app_user;



----------  END TABLE POLICY: auth.app_user
--==
----------
----------  BEGIN TABLE POLICY: auth.token
----------  POLICY NAME:  Default Table Policy - NO ACCESS
----------

----------  REMOVE EXISTING TABLE GRANTS

  revoke all privileges 
  on table auth.token 
  from public;

  revoke all privileges 
  on table auth.token 
  from app_super_admin, app_tenant_admin, app_admin, app_demon, app_user, app_anonymous;

----------  DISABLE ROW LEVEL SECURITY

  alter table auth.token disable row level security;

----------  CREATE NEW TABLE GRANTS


----------  END TABLE POLICY: auth.token
--==
----------
----------  BEGIN TABLE POLICY: lcb.lcb_license
----------  POLICY NAME:  app_user  select only no rls  :::  app_super_admin manage
----------

----------  REMOVE EXISTING TABLE GRANTS

  revoke all privileges 
  on table lcb.lcb_license 
  from public;

  revoke all privileges 
  on table lcb.lcb_license 
  from app_super_admin, app_tenant_admin, app_admin, app_demon, app_user, app_anonymous;

----------  DISABLE ROW LEVEL SECURITY

  alter table lcb.lcb_license disable row level security;

----------  CREATE NEW TABLE GRANTS

----------  app_super_admin
  grant 
    insert, -- ( id, created_at, updated_at, code ), 
        -- no excluded columns
    update, -- ( id, created_at, updated_at, code ),
        -- no excluded columns
    delete  
  on table lcb.lcb_license 
  to app_super_admin;


----------  app_user
  grant 
    select  
  on table lcb.lcb_license 
  to app_user;



----------  END TABLE POLICY: lcb.lcb_license
--==
----------
----------  BEGIN TABLE POLICY: lcb.lcb_license_holder
----------  POLICY NAME:  app_user  select only no rls  :::  app_super_admin manage
----------

----------  REMOVE EXISTING TABLE GRANTS

  revoke all privileges 
  on table lcb.lcb_license_holder 
  from public;

  revoke all privileges 
  on table lcb.lcb_license_holder 
  from app_super_admin, app_tenant_admin, app_admin, app_demon, app_user, app_anonymous;

----------  DISABLE ROW LEVEL SECURITY

  alter table lcb.lcb_license_holder disable row level security;

----------  CREATE NEW TABLE GRANTS

----------  app_super_admin
  grant 
    insert, -- ( id, created_at, updated_at, lcb_license_id, organization_id, acquisition_date, relinquish_date ), 
        -- no excluded columns
    update, -- ( id, created_at, updated_at, lcb_license_id, organization_id, acquisition_date, relinquish_date ),
        -- no excluded columns
    delete  
  on table lcb.lcb_license_holder 
  to app_super_admin;


----------  app_user
  grant 
    select  
  on table lcb.lcb_license_holder 
  to app_user;



----------  END TABLE POLICY: lcb.lcb_license_holder
--==
----------
----------  BEGIN TABLE POLICY: lcb.inventory_lot
----------  POLICY NAME:  app_user default with rls
----------

----------  REMOVE EXISTING TABLE GRANTS

  revoke all privileges 
  on table lcb.inventory_lot 
  from public;

  revoke all privileges 
  on table lcb.inventory_lot 
  from app_super_admin, app_tenant_admin, app_admin, app_demon, app_user, app_anonymous;

----------  ENABLE ROW LEVEL SECURITY

  alter table lcb.inventory_lot enable row level security;

  create policy rls_app_user_default_lcb_inventory_lot 
    on lcb.inventory_lot
    as permissive
    for all
    to app_user
    using ( auth_fn.app_user_has_access(app_tenant_id) = true)
    ;


----------  CREATE NEW TABLE GRANTS

----------  app_user
  grant 
    select , 
    insert, -- ( id, lcb_license_holder_id, created_at, updated_at, deleted_at, id_origin, inventory_type, description, quantity, units, strain_name, area_identifier ), 
        -- no excluded columns
    update, -- ( id, lcb_license_holder_id, created_at, updated_at, deleted_at, id_origin, inventory_type, description, quantity, units, strain_name, area_identifier ), 
        -- no excluded columns
    delete  
  on table lcb.inventory_lot 
  to app_user;



----------  END TABLE POLICY: lcb.inventory_lot
--==
----------
----------  BEGIN TABLE POLICY: org.config_org
----------  POLICY NAME:  Default Table Policy - NO ACCESS
----------

----------  REMOVE EXISTING TABLE GRANTS

  revoke all privileges 
  on table org.config_org 
  from public;

  revoke all privileges 
  on table org.config_org 
  from app_super_admin, app_tenant_admin, app_admin, app_demon, app_user, app_anonymous;

----------  DISABLE ROW LEVEL SECURITY

  alter table org.config_org disable row level security;

----------  CREATE NEW TABLE GRANTS


----------  END TABLE POLICY: org.config_org
--==
----------
----------  BEGIN TABLE POLICY: org.contact
----------  POLICY NAME:  app_user default with rls
----------

----------  REMOVE EXISTING TABLE GRANTS

  revoke all privileges 
  on table org.contact 
  from public;

  revoke all privileges 
  on table org.contact 
  from app_super_admin, app_tenant_admin, app_admin, app_demon, app_user, app_anonymous;

----------  ENABLE ROW LEVEL SECURITY

  alter table org.contact enable row level security;

  create policy rls_app_user_default_org_contact 
    on org.contact
    as permissive
    for all
    to app_user
    using ( auth_fn.app_user_has_access(app_tenant_id) = true )
    ;


----------  CREATE NEW TABLE GRANTS

----------  app_user
  grant 
    select , 
    insert, -- ( id, app_tenant_id, created_at, updated_at, organization_id, location_id, external_id, first_name, last_name, email, cell_phone, office_phone, title, nickname ), 
        -- no excluded columns
    update, -- ( id, app_tenant_id, created_at, updated_at, organization_id, location_id, external_id, first_name, last_name, email, cell_phone, office_phone, title, nickname ), 
        -- no excluded columns
    delete  
  on table org.contact 
  to app_user;



----------  END TABLE POLICY: org.contact
--==
----------
----------  BEGIN TABLE POLICY: org.facility
----------  POLICY NAME:  app_user default with rls
----------

----------  REMOVE EXISTING TABLE GRANTS

  revoke all privileges 
  on table org.facility 
  from public;

  revoke all privileges 
  on table org.facility 
  from app_super_admin, app_tenant_admin, app_admin, app_demon, app_user, app_anonymous;

----------  ENABLE ROW LEVEL SECURITY

  alter table org.facility enable row level security;

  create policy rls_app_user_default_org_facility 
    on org.facility
    as permissive
    for all
    to app_user
    using ( auth_fn.app_user_has_access(app_tenant_id) = true )
    ;


----------  CREATE NEW TABLE GRANTS

----------  app_user
  grant 
    select , 
    insert, -- ( id, app_tenant_id, created_at, updated_at, organization_id, location_id, name, external_id ), 
        -- no excluded columns
    update, -- ( id, app_tenant_id, created_at, updated_at, organization_id, location_id, name, external_id ), 
        -- no excluded columns
    delete  
  on table org.facility 
  to app_user;



----------  END TABLE POLICY: org.facility
--==
----------
----------  BEGIN TABLE POLICY: org.location
----------  POLICY NAME:  app_user default with rls
----------

----------  REMOVE EXISTING TABLE GRANTS

  revoke all privileges 
  on table org.location 
  from public;

  revoke all privileges 
  on table org.location 
  from app_super_admin, app_tenant_admin, app_admin, app_demon, app_user, app_anonymous;

----------  ENABLE ROW LEVEL SECURITY

  alter table org.location enable row level security;

  create policy rls_app_user_default_org_location 
    on org.location
    as permissive
    for all
    to app_user
    using ( auth_fn.app_user_has_access(app_tenant_id) = true )
    ;


----------  CREATE NEW TABLE GRANTS

----------  app_user
  grant 
    select , 
    insert, -- ( id, app_tenant_id, created_at, updated_at, external_id, name, address1, address2, city, state, zip, lat, lon ), 
        -- no excluded columns
    update, -- ( id, app_tenant_id, created_at, updated_at, external_id, name, address1, address2, city, state, zip, lat, lon ), 
        -- no excluded columns
    delete  
  on table org.location 
  to app_user;



----------  END TABLE POLICY: org.location
--==
----------
----------  BEGIN TABLE POLICY: org.organization
----------  POLICY NAME:  app_user default with rls
----------

----------  REMOVE EXISTING TABLE GRANTS

  revoke all privileges 
  on table org.organization 
  from public;

  revoke all privileges 
  on table org.organization 
  from app_super_admin, app_tenant_admin, app_admin, app_demon, app_user, app_anonymous;

----------  ENABLE ROW LEVEL SECURITY

  alter table org.organization enable row level security;

  create policy rls_app_user_default_org_organization 
    on org.organization
    as permissive
    for all
    to app_user
    using ( auth_fn.app_user_has_access(app_tenant_id) = true )
    ;


----------  CREATE NEW TABLE GRANTS

----------  app_user
  grant 
    select , 
    insert, -- ( id, app_tenant_id, actual_app_tenant_id, created_at, updated_at, external_id, name, location_id, primary_contact_id ), 
        -- no excluded columns
    update, -- ( id, app_tenant_id, actual_app_tenant_id, created_at, updated_at, external_id, name, location_id, primary_contact_id ), 
        -- no excluded columns
    delete  
  on table org.organization 
  to app_user;



----------  END TABLE POLICY: org.organization
--==
----------
----------  BEGIN TABLE POLICY: org.contact_app_user
----------  POLICY NAME:  app_user default with rls
----------

----------  REMOVE EXISTING TABLE GRANTS

  revoke all privileges 
  on table org.contact_app_user 
  from public;

  revoke all privileges 
  on table org.contact_app_user 
  from app_super_admin, app_tenant_admin, app_admin, app_demon, app_user, app_anonymous;

----------  ENABLE ROW LEVEL SECURITY

  alter table org.contact_app_user enable row level security;

  create policy rls_app_user_default_org_contact_app_user 
    on org.contact_app_user
    as permissive
    for all
    to app_user
    using ( auth_fn.app_user_has_access(app_tenant_id) = true )
    ;


----------  CREATE NEW TABLE GRANTS

----------  app_user
  grant 
    select , 
    insert, -- ( id, app_tenant_id, created_at, updated_at, contact_id, app_user_id, username ), 
        -- no excluded columns
    update, -- ( id, app_tenant_id, created_at, updated_at, contact_id, app_user_id, username ), 
        -- no excluded columns
    delete  
  on table org.contact_app_user 
  to app_user;



----------  END TABLE POLICY: org.contact_app_user
--==


--==
----------
----------  BEGIN TABLE POLICY: lcb_hist.hist_inventory_lot
----------  POLICY NAME:  app_user default with rls
----------

----------  REMOVE EXISTING TABLE GRANTS

  revoke all privileges 
  on table lcb_hist.hist_inventory_lot 
  from public;

  revoke all privileges 
  on table lcb_hist.hist_inventory_lot 
  from app_super_admin, app_tenant_admin, app_admin, app_demon, app_user, app_anonymous;

----------  ENABLE ROW LEVEL SECURITY

  alter table lcb_hist.hist_inventory_lot enable row level security;

  create policy rls_app_user_default_org_contact_app_user 
    on lcb_hist.hist_inventory_lot
    as permissive
    for all
    to app_user
    using ( auth_fn.app_user_has_access(app_tenant_id) = true )
    ;


----------  CREATE NEW TABLE GRANTS

----------  app_user
  grant 
    select , 
    insert, -- ( id, app_tenant_id, created_at, updated_at, contact_id, app_user_id, username ), 
        -- no excluded columns
    update, -- ( id, app_tenant_id, created_at, updated_at, contact_id, app_user_id, username ), 
        -- no excluded columns
    delete  
  on table lcb_hist.hist_inventory_lot 
  to app_user;



----------  END TABLE POLICY: lcb_hist.hist_inventory_lot
--==



----------
----------  BEGIN TABLE POLICY: lcb_ref.inventory_lot_reporting_status
----------  POLICY NAME:  app_user  select only no rls  :::  app_super_admin manage
----------

----------  REMOVE EXISTING TABLE GRANTS

  revoke all privileges 
  on table lcb_ref.inventory_lot_reporting_status 
  from public;

  revoke all privileges 
  on table lcb_ref.inventory_lot_reporting_status 
  from app_super_admin, app_tenant_admin, app_admin, app_demon, app_user, app_anonymous;

----------  DISABLE ROW LEVEL SECURITY

  alter table lcb_ref.inventory_lot_reporting_status disable row level security;

----------  CREATE NEW TABLE GRANTS

----------  app_super_admin
  grant 
    insert ( id ), 
        -- no excluded columns
    update ( id ),
        -- no excluded columns
    delete  
  on table lcb_ref.inventory_lot_reporting_status 
  to app_super_admin;


----------  app_user
  grant 
    select  
  on table lcb_ref.inventory_lot_reporting_status 
  to app_user;



----------  END TABLE POLICY: lcb_ref.inventory_lot_reporting_status
--==
----------
----------  BEGIN TABLE POLICY: lcb_ref.inventory_type
----------  POLICY NAME:  app_user  select only no rls  :::  app_super_admin manage
----------

----------  REMOVE EXISTING TABLE GRANTS

  revoke all privileges 
  on table lcb_ref.inventory_type 
  from public;

  revoke all privileges 
  on table lcb_ref.inventory_type 
  from app_super_admin, app_tenant_admin, app_admin, app_demon, app_user, app_anonymous;

----------  DISABLE ROW LEVEL SECURITY

  alter table lcb_ref.inventory_type disable row level security;

----------  CREATE NEW TABLE GRANTS

----------  app_super_admin
  grant 
    insert ( id, name, description ), 
        -- no excluded columns
    update ( id, name, description ),
        -- no excluded columns
    delete  
  on table lcb_ref.inventory_type 
  to app_super_admin;


----------  app_user
  grant 
    select  
  on table lcb_ref.inventory_type 
  to app_user;



----------  END TABLE POLICY: lcb_ref.inventory_type
--==


----------  BEGIN TABLE POLICY: lcb_ref.conversion_rule
----------  POLICY NAME:  app_user  select only no rls  :::  app_super_admin manage
----------

----------  REMOVE EXISTING TABLE GRANTS

  revoke all privileges 
  on table lcb_ref.conversion_rule 
  from public;

  revoke all privileges 
  on table lcb_ref.conversion_rule 
  from app_super_admin, app_tenant_admin, app_admin, app_demon, app_user, app_anonymous;

----------  DISABLE ROW LEVEL SECURITY

  alter table lcb_ref.conversion_rule disable row level security;

----------  CREATE NEW TABLE GRANTS

----------  app_super_admin
  grant 
    insert, 
        -- no excluded columns
    update,
        -- no excluded columns
    delete  
  on table lcb_ref.conversion_rule 
  to app_super_admin;


----------  app_user
  grant 
    select  
  on table lcb_ref.conversion_rule 
  to app_user;



----------  END TABLE POLICY: lcb_ref.conversion_rule
--==


----------
----------  BEGIN TABLE POLICY: lcb.conversion
----------  POLICY NAME:  app_user  select only no rls  :::  app_super_admin manage
----------

----------  REMOVE EXISTING TABLE GRANTS

  revoke all privileges 
  on table lcb.conversion 
  from public;

  revoke all privileges 
  on table lcb.conversion 
  from app_super_admin, app_tenant_admin, app_admin, app_demon, app_user, app_anonymous;

----------  DISABLE ROW LEVEL SECURITY

  alter table lcb.conversion disable row level security;

  create policy rls_app_user_default_lcb_conversion 
    on lcb.conversion
    as permissive
    for all
    to app_user
    using ( auth_fn.app_user_has_access(app_tenant_id) = true)
    ;


----------  CREATE NEW TABLE GRANTS

----------  app_user
  grant 
    select , 
    insert, -- ( id, lcb_license_holder_id, created_at, updated_at, deleted_at, id_origin, inventory_type, description, quantity, units, strain_name, area_identifier ), 
        -- no excluded columns
    update, -- ( id, lcb_license_holder_id, created_at, updated_at, deleted_at, id_origin, inventory_type, description, quantity, units, strain_name, area_identifier ), 
        -- no excluded columns
    delete  
  on table lcb.conversion 
  to app_user;


----------  END TABLE POLICY: lcb.conversion
--==


----------
----------  BEGIN TABLE POLICY: lcb.conversion_source
----------  POLICY NAME:  app_user  select only no rls  :::  app_super_admin manage
----------

----------  REMOVE EXISTING TABLE GRANTS

  revoke all privileges 
  on table lcb.conversion_source 
  from public;

  revoke all privileges 
  on table lcb.conversion_source 
  from app_super_admin, app_tenant_admin, app_admin, app_demon, app_user, app_anonymous;

----------  DISABLE ROW LEVEL SECURITY

  alter table lcb.conversion_source disable row level security;

  create policy rls_app_user_default_lcb_conversion_source
    on lcb.conversion_source
    as permissive
    for all
    to app_user
    using ( auth_fn.app_user_has_access(app_tenant_id) = true)
    ;


----------  CREATE NEW TABLE GRANTS

----------  app_user
  grant 
    select , 
    insert, -- ( id, lcb_license_holder_id, created_at, updated_at, deleted_at, id_origin, inventory_type, description, quantity, units, strain_name, area_identifier ), 
        -- no excluded columns
    update, -- ( id, lcb_license_holder_id, created_at, updated_at, deleted_at, id_origin, inventory_type, description, quantity, units, strain_name, area_identifier ), 
        -- no excluded columns
    delete  
  on table lcb.conversion_source
  to app_user;


----------  END TABLE POLICY: lcb.conversion_source
--==



----------
----------  BEGIN TABLE POLICY: lcb.conversion_result
----------  POLICY NAME:  app_user  select only no rls  :::  app_super_admin manage
----------

----------  REMOVE EXISTING TABLE GRANTS

  revoke all privileges 
  on table lcb.conversion_result 
  from public;

  revoke all privileges 
  on table lcb.conversion_result 
  from app_super_admin, app_tenant_admin, app_admin, app_demon, app_user, app_anonymous;

----------  DISABLE ROW LEVEL SECURITY

  alter table lcb.conversion_result disable row level security;

  create policy rls_app_user_default_lcb_conversion_result
    on lcb.conversion_result
    as permissive
    for all
    to app_user
    using ( auth_fn.app_user_has_access(app_tenant_id) = true)
    ;


----------  CREATE NEW TABLE GRANTS

----------  app_user
  grant 
    select , 
    insert, -- ( id, lcb_license_holder_id, created_at, updated_at, deleted_at, id_origin, inventory_type, description, quantity, units, strain_name, area_identifier ), 
        -- no excluded columns
    update, -- ( id, lcb_license_holder_id, created_at, updated_at, deleted_at, id_origin, inventory_type, description, quantity, units, strain_name, area_identifier ), 
        -- no excluded columns
    delete  
  on table lcb.conversion_result
  to app_user;



----------  END TABLE POLICY: lcb.conversion_result
--==