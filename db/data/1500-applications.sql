-- Deploy app:seed-data to pg
-- requires: schema

BEGIN;

--------------------------------------------------   tenant manager
  insert into app.application(
    name 
    ,key
  ) 
  values (
    'Tenant Manager'
    ,'tenant-manager'
  )
  on conflict(key) 
  do nothing
  ;

  insert into app.license_type(
    name
    ,key
    ,application_id
  )
  values
  (
    'Tenant Manager'
    ,'tenant-manager'
    ,(select id from app.application where key = 'tenant-manager')
  )
  on conflict(key) 
  do nothing
  ;

  insert into app.license(
    app_tenant_id
    ,license_type_id
    ,name
    ,assigned_to_app_user_id
  )
  select
    au.app_tenant_id
    ,(select id from app.license_type where key = 'tenant-manager')
    ,au.username || ' - ' || (select name from app.license_type where key = 'tenant-manager')
    ,au.id
  from auth.app_user au
  where au.permission_key in (
    'SuperAdmin'
    -- ,'Admin'
  )
  on conflict (assigned_to_app_user_id, license_type_id)
  do nothing
  ;

--------------------------------------------------   license manager
  insert into app.application(
    name 
    ,key
  ) 
  values (
    'License Manager'
    ,'license-manager'
  )
  on conflict(key) 
  do nothing
  ;

  insert into app.license_type(
    name
    ,key
    ,application_id
  )
  values
  (
    'License Manager'
    ,'license-manager'
    ,(select id from app.application where key = 'license-manager')
  )
  on conflict(key) 
  do nothing
  ;

  insert into app.license(
    app_tenant_id
    ,license_type_id
    ,name
    ,assigned_to_app_user_id
  )
  select
    au.app_tenant_id
    ,(select id from app.license_type where key = 'license-manager')
    ,au.username || ' - ' || (select name from app.license_type where key = 'license-manager')
    ,au.id
  from auth.app_user au
  where au.permission_key in ('SuperAdmin', 'Admin')
  on conflict (assigned_to_app_user_id, license_type_id)
  do nothing
  ;

--------------------------------------------------   address book
  insert into app.application(
    name 
    ,key
  ) 
  values (
    'address book'
    ,'address-book'
  )
  on conflict(key) 
  do nothing
  ;

  insert into app.license_type(
    name
    ,key
    ,application_id
  )
  values
  (
    'Address Book'
    ,'address-book'
    ,(select id from app.application where key = 'address-book')
  )
  on conflict(key) 
  do nothing
  ;

  insert into app.license(
    app_tenant_id
    ,license_type_id
    ,name
    ,assigned_to_app_user_id
  )
  select
    au.app_tenant_id
    ,(select id from app.license_type where key = 'address-book')
    ,au.username || ' - ' || (select name from app.license_type where key = 'address-book')
    ,au.id
  from auth.app_user au
  on conflict (assigned_to_app_user_id, license_type_id)
  do nothing
  ;

\echo
\echo application
\echo ----------------------------------
select * from app.application;
\echo
\echo license_type
\echo ----------------------------------
select * from app.license_type;
\echo
\echo license
\echo ----------------------------------
select * from app.license;

--------------------------------------------------   inventory manager
  insert into app.application(
    name 
    ,key
  ) 
  values (
    'Inventory'
    ,'trc-inv'
  )
  on conflict(key) 
  do nothing
  ;

  insert into app.license_type(
    name
    ,key
    ,application_id
  )
  values
  (
    'Inventory'
    ,'trc-inv'
    ,(select id from app.application where key = 'trc-inv')
  )
  on conflict(key) 
  do nothing
  ;

  insert into app.license(
    app_tenant_id
    ,license_type_id
    ,name
    ,assigned_to_app_user_id
  )
  select
    au.app_tenant_id
    ,(select id from app.license_type where key = 'trc-inv')
    ,au.username || ' - ' || (select name from app.license_type where key = 'trc-inv')
    ,au.id
  from auth.app_user au
  where au.permission_key in ('SuperAdmin', 'Admin', 'User')
  on conflict (assigned_to_app_user_id, license_type_id)
  do nothing
  ;

--------------------------------------------------   manifest manager
  insert into app.application(
    name 
    ,key
  ) 
  values (
    'Manifests'
    ,'trc-manifest'
  )
  on conflict(key) 
  do nothing
  ;

  insert into app.license_type(
    name
    ,key
    ,application_id
  )
  values
  (
    'Manifests'
    ,'trc-manifest'
    ,(select id from app.application where key = 'trc-manifest')
  )
  on conflict(key) 
  do nothing
  ;

  insert into app.license(
    app_tenant_id
    ,license_type_id
    ,name
    ,assigned_to_app_user_id
  )
  select
    au.app_tenant_id
    ,(select id from app.license_type where key = 'trc-manifest')
    ,au.username || ' - ' || (select name from app.license_type where key = 'trc-manifest')
    ,au.id
  from auth.app_user au
  where au.permission_key in ('SuperAdmin', 'Admin', 'User')
  on conflict (assigned_to_app_user_id, license_type_id)
  do nothing
  ;

--------------------------------------------------   transfer manager
  insert into app.application(
    name 
    ,key
  ) 
  values (
    'Transfers'
    ,'trc-xfer'
  )
  on conflict(key) 
  do nothing
  ;

  insert into app.license_type(
    name
    ,key
    ,application_id
  )
  values
  (
    'Transfers'
    ,'trc-xfer'
    ,(select id from app.application where key = 'trc-xfer')
  )
  on conflict(key) 
  do nothing
  ;

  insert into app.license(
    app_tenant_id
    ,license_type_id
    ,name
    ,assigned_to_app_user_id
  )
  select
    au.app_tenant_id
    ,(select id from app.license_type where key = 'trc-xfer')
    ,au.username || ' - ' || (select name from app.license_type where key = 'trc-xfer')
    ,au.id
  from auth.app_user au
  where au.permission_key in ('SuperAdmin', 'Admin', 'User')
  on conflict (assigned_to_app_user_id, license_type_id)
  do nothing
  ;

--------------------------------------------------   delivery manager
  insert into app.application(
    name 
    ,key
  ) 
  values (
    'Deliveries'
    ,'trc-delivery'
  )
  on conflict(key) 
  do nothing
  ;

  insert into app.license_type(
    name
    ,key
    ,application_id
  )
  values
  (
    'Deliveries'
    ,'trc-delivery'
    ,(select id from app.application where key = 'trc-delivery')
  )
  on conflict(key) 
  do nothing
  ;

  insert into app.license(
    app_tenant_id
    ,license_type_id
    ,name
    ,assigned_to_app_user_id
  )
  select
    au.app_tenant_id
    ,(select id from app.license_type where key = 'trc-delivery')
    ,au.username || ' - ' || (select name from app.license_type where key = 'trc-delivery')
    ,au.id
  from auth.app_user au
  where au.permission_key in ('SuperAdmin', 'Admin', 'User')
  on conflict (assigned_to_app_user_id, license_type_id)
  do nothing
  ;

--------------------------------------------------   receiving manager
  insert into app.application(
    name 
    ,key
  ) 
  values (
    'Receiving'
    ,'trc-rec'
  )
  on conflict(key) 
  do nothing
  ;

  insert into app.license_type(
    name
    ,key
    ,application_id
  )
  values
  (
    'Receiving'
    ,'trc-rec'
    ,(select id from app.application where key = 'trc-rec')
  )
  on conflict(key) 
  do nothing
  ;

  insert into app.license(
    app_tenant_id
    ,license_type_id
    ,name
    ,assigned_to_app_user_id
  )
  select
    au.app_tenant_id
    ,(select id from app.license_type where key = 'trc-rec')
    ,au.username || ' - ' || (select name from app.license_type where key = 'trc-rec')
    ,au.id
  from auth.app_user au
  where au.permission_key in ('SuperAdmin', 'Admin', 'User')
  on conflict (assigned_to_app_user_id, license_type_id)
  do nothing
  ;

--------------------------------------------------   returns manager
  insert into app.application(
    name 
    ,key
  ) 
  values (
    'Returns'
    ,'trc-ret'
  )
  on conflict(key) 
  do nothing
  ;

  insert into app.license_type(
    name
    ,key
    ,application_id
  )
  values
  (
    'Returns'
    ,'trc-ret'
    ,(select id from app.application where key = 'trc-ret')
  )
  on conflict(key) 
  do nothing
  ;

  insert into app.license(
    app_tenant_id
    ,license_type_id
    ,name
    ,assigned_to_app_user_id
  )
  select
    au.app_tenant_id
    ,(select id from app.license_type where key = 'trc-ret')
    ,au.username || ' - ' || (select name from app.license_type where key = 'trc-ret')
    ,au.id
  from auth.app_user au
  where au.permission_key in ('SuperAdmin', 'Admin', 'User')
  on conflict (assigned_to_app_user_id, license_type_id)
  do nothing
  ;

--------------------------------------------------   qa sampling
  insert into app.application(
    name 
    ,key
  ) 
  values (
    'Qa Sampling'
    ,'trc-qa-sampling'
  )
  on conflict(key) 
  do nothing
  ;

  insert into app.license_type(
    name
    ,key
    ,application_id
  )
  values
  (
    'Qa Sampling'
    ,'trc-qa-sampling'
    ,(select id from app.application where key = 'trc-qa-sampling')
  )
  on conflict(key) 
  do nothing
  ;

  insert into app.license(
    app_tenant_id
    ,license_type_id
    ,name
    ,assigned_to_app_user_id
  )
  select
    au.app_tenant_id
    ,(select id from app.license_type where key = 'trc-qa-sampling')
    ,au.username || ' - ' || (select name from app.license_type where key = 'trc-qa-sampling')
    ,au.id
  from auth.app_user au
  where au.permission_key in ('SuperAdmin', 'Admin', 'User')
  on conflict (assigned_to_app_user_id, license_type_id)
  do nothing
  ;

--------------------------------------------------   qa lab reporting
  insert into app.application(
    name 
    ,key
  ) 
  values (
    'Qa Lab Reporting'
    ,'trc-qa-lab-reporting'
  )
  on conflict(key) 
  do nothing
  ;

  insert into app.license_type(
    name
    ,key
    ,application_id
  )
  values
  (
    'Qa Lab Reporting'
    ,'trc-qa-lab-reporting'
    ,(select id from app.application where key = 'trc-qa-lab-reporting')
  )
  on conflict(key) 
  do nothing
  ;

  insert into app.license(
    app_tenant_id
    ,license_type_id
    ,name
    ,assigned_to_app_user_id
  )
  select
    au.app_tenant_id
    ,(select id from app.license_type where key = 'trc-qa-lab-reporting')
    ,au.username || ' - ' || (select name from app.license_type where key = 'trc-qa-lab-reporting')
    ,au.id
  from auth.app_user au
  where au.permission_key in ('SuperAdmin', 'Admin', 'User')
  on conflict (assigned_to_app_user_id, license_type_id)
  do nothing
  ;

--------------------------------------------------   retail sampling
  insert into app.application(
    name 
    ,key
  ) 
  values (
    'Retail Sampling'
    ,'trc-retail-sampling'
  )
  on conflict(key) 
  do nothing
  ;

  insert into app.license_type(
    name
    ,key
    ,application_id
  )
  values
  (
    'Retail Sampling'
    ,'trc-retail-sampling'
    ,(select id from app.application where key = 'trc-retail-sampling')
  )
  on conflict(key) 
  do nothing
  ;

  insert into app.license(
    app_tenant_id
    ,license_type_id
    ,name
    ,assigned_to_app_user_id
  )
  select
    au.app_tenant_id
    ,(select id from app.license_type where key = 'trc-retail-sampling')
    ,au.username || ' - ' || (select name from app.license_type where key = 'trc-retail-sampling')
    ,au.id
  from auth.app_user au
  where au.permission_key in ('SuperAdmin', 'Admin', 'User')
  on conflict (assigned_to_app_user_id, license_type_id)
  do nothing
  ;

--------------------------------------------------   retail sales reporting
  insert into app.application(
    name 
    ,key
  ) 
  values (
    'Retail Sales Reporting'
    ,'trc-retail-sales-reporting'
  )
  on conflict(key) 
  do nothing
  ;

  insert into app.license_type(
    name
    ,key
    ,application_id
  )
  values
  (
    'Retail Sales Reporting'
    ,'trc-retail-sales-reporting'
    ,(select id from app.application where key = 'trc-retail-sales-reporting')
  )
  on conflict(key) 
  do nothing
  ;

  insert into app.license(
    app_tenant_id
    ,license_type_id
    ,name
    ,assigned_to_app_user_id
  )
  select
    au.app_tenant_id
    ,(select id from app.license_type where key = 'trc-retail-sales-reporting')
    ,au.username || ' - ' || (select name from app.license_type where key = 'trc-retail-sales-reporting')
    ,au.id
  from auth.app_user au
  where au.permission_key in ('SuperAdmin', 'Admin', 'User')
  on conflict (assigned_to_app_user_id, license_type_id)
  do nothing
  ;

--------------------------------------------------   seed-sourcing
  insert into app.application(
    name 
    ,key
  ) 
  values (
    'Seed Sourcing'
    ,'trc-seed-sourcing'
  )
  on conflict(key) 
  do nothing
  ;

  insert into app.license_type(
    name
    ,key
    ,application_id
  )
  values
  (
    'Seed Sourcing'
    ,'trc-seed-sourcing'
    ,(select id from app.application where key = 'trc-seed-sourcing')
  )
  on conflict(key) 
  do nothing
  ;

  insert into app.license(
    app_tenant_id
    ,license_type_id
    ,name
    ,assigned_to_app_user_id
  )
  select
    au.app_tenant_id
    ,(select id from app.license_type where key = 'trc-seed-sourcing')
    ,au.username || ' - ' || (select name from app.license_type where key = 'trc-seed-sourcing')
    ,au.id
  from auth.app_user au
  where au.permission_key in ('SuperAdmin', 'Admin', 'User')
  on conflict (assigned_to_app_user_id, license_type_id)
  do nothing
  ;

--------------------------------------------------   planting
  insert into app.application(
    name 
    ,key
  ) 
  values (
    'Planting'
    ,'trc-planting'
  )
  on conflict(key) 
  do nothing
  ;

  insert into app.license_type(
    name
    ,key
    ,application_id
  )
  values
  (
    'Planting'
    ,'trc-planting'
    ,(select id from app.application where key = 'trc-planting')
  )
  on conflict(key) 
  do nothing
  ;

  insert into app.license(
    app_tenant_id
    ,license_type_id
    ,name
    ,assigned_to_app_user_id
  )
  select
    au.app_tenant_id
    ,(select id from app.license_type where key = 'trc-planting')
    ,au.username || ' - ' || (select name from app.license_type where key = 'trc-planting')
    ,au.id
  from auth.app_user au
  where au.permission_key in ('SuperAdmin', 'Admin', 'User')
  on conflict (assigned_to_app_user_id, license_type_id)
  do nothing
  ;

--------------------------------------------------   cloning
  insert into app.application(
    name 
    ,key
  ) 
  values (
    'Cloning'
    ,'trc-cloning'
  )
  on conflict(key) 
  do nothing
  ;

  insert into app.license_type(
    name
    ,key
    ,application_id
  )
  values
  (
    'Cloning'
    ,'trc-cloning'
    ,(select id from app.application where key = 'trc-cloning')
  )
  on conflict(key) 
  do nothing
  ;

  insert into app.license(
    app_tenant_id
    ,license_type_id
    ,name
    ,assigned_to_app_user_id
  )
  select
    au.app_tenant_id
    ,(select id from app.license_type where key = 'trc-cloning')
    ,au.username || ' - ' || (select name from app.license_type where key = 'trc-cloning')
    ,au.id
  from auth.app_user au
  where au.permission_key in ('SuperAdmin', 'Admin', 'User')
  on conflict (assigned_to_app_user_id, license_type_id)
  do nothing
  ;

--------------------------------------------------   growing
  insert into app.application(
    name 
    ,key
  ) 
  values (
    'Growing'
    ,'trc-growing'
  )
  on conflict(key) 
  do nothing
  ;

  insert into app.license_type(
    name
    ,key
    ,application_id
  )
  values
  (
    'Growing'
    ,'trc-growing'
    ,(select id from app.application where key = 'trc-growing')
  )
  on conflict(key) 
  do nothing
  ;

  insert into app.license(
    app_tenant_id
    ,license_type_id
    ,name
    ,assigned_to_app_user_id
  )
  select
    au.app_tenant_id
    ,(select id from app.license_type where key = 'trc-growing')
    ,au.username || ' - ' || (select name from app.license_type where key = 'trc-growing')
    ,au.id
  from auth.app_user au
  where au.permission_key in ('SuperAdmin', 'Admin', 'User')
  on conflict (assigned_to_app_user_id, license_type_id)
  do nothing
  ;

--------------------------------------------------   harvest
  insert into app.application(
    name 
    ,key
  ) 
  values (
    'Harvesting'
    ,'trc-harvesting'
  )
  on conflict(key) 
  do nothing
  ;

  insert into app.license_type(
    name
    ,key
    ,application_id
  )
  values
  (
    'Harvesting'
    ,'trc-harvesting'
    ,(select id from app.application where key = 'trc-harvesting')
  )
  on conflict(key) 
  do nothing
  ;

  insert into app.license(
    app_tenant_id
    ,license_type_id
    ,name
    ,assigned_to_app_user_id
  )
  select
    au.app_tenant_id
    ,(select id from app.license_type where key = 'trc-harvesting')
    ,au.username || ' - ' || (select name from app.license_type where key = 'trc-harvesting')
    ,au.id
  from auth.app_user au
  where au.permission_key in ('SuperAdmin', 'Admin', 'User')
  on conflict (assigned_to_app_user_id, license_type_id)
  do nothing
  ;

--------------------------------------------------   cure
  insert into app.application(
    name 
    ,key
  ) 
  values (
    'Curing'
    ,'trc-curing'
  )
  on conflict(key) 
  do nothing
  ;

  insert into app.license_type(
    name
    ,key
    ,application_id
  )
  values
  (
    'Curing'
    ,'trc-curing'
    ,(select id from app.application where key = 'trc-curing')
  )
  on conflict(key) 
  do nothing
  ;

  insert into app.license(
    app_tenant_id
    ,license_type_id
    ,name
    ,assigned_to_app_user_id
  )
  select
    au.app_tenant_id
    ,(select id from app.license_type where key = 'trc-curing')
    ,au.username || ' - ' || (select name from app.license_type where key = 'trc-curing')
    ,au.id
  from auth.app_user au
  where au.permission_key in ('SuperAdmin', 'Admin', 'User')
  on conflict (assigned_to_app_user_id, license_type_id)
  do nothing
  ;

--------------------------------------------------   flower lotting
  insert into app.application(
    name 
    ,key
  ) 
  values (
    'Flower Lotting'
    ,'trc-flower-lotting'
  )
  on conflict(key) 
  do nothing
  ;

  insert into app.license_type(
    name
    ,key
    ,application_id
  )
  values
  (
    'Flower Lotting'
    ,'trc-flower-lotting'
    ,(select id from app.application where key = 'trc-flower-lotting')
  )
  on conflict(key) 
  do nothing
  ;

  insert into app.license(
    app_tenant_id
    ,license_type_id
    ,name
    ,assigned_to_app_user_id
  )
  select
    au.app_tenant_id
    ,(select id from app.license_type where key = 'trc-flower-lotting')
    ,au.username || ' - ' || (select name from app.license_type where key = 'trc-flower-lotting')
    ,au.id
  from auth.app_user au
  where au.permission_key in ('SuperAdmin', 'Admin', 'User')
  on conflict (assigned_to_app_user_id, license_type_id)
  do nothing
  ;

--------------------------------------------------   flower processing
  insert into app.application(
    name 
    ,key
  ) 
  values (
    'Flower Processing'
    ,'trc-flower-processing'
  )
  on conflict(key) 
  do nothing
  ;

  insert into app.license_type(
    name
    ,key
    ,application_id
  )
  values
  (
    'Flower Processing'
    ,'trc-flower-processing'
    ,(select id from app.application where key = 'trc-flower-processing')
  )
  on conflict(key) 
  do nothing
  ;

  insert into app.license(
    app_tenant_id
    ,license_type_id
    ,name
    ,assigned_to_app_user_id
  )
  select
    au.app_tenant_id
    ,(select id from app.license_type where key = 'trc-flower-processing')
    ,au.username || ' - ' || (select name from app.license_type where key = 'trc-flower-processing')
    ,au.id
  from auth.app_user au
  where au.permission_key in ('SuperAdmin', 'Admin', 'User')
  on conflict (assigned_to_app_user_id, license_type_id)
  do nothing
  ;

--------------------------------------------------   product processing
  insert into app.application(
    name 
    ,key
  ) 
  values (
    'Product Packaging'
    ,'trc-product-processing'
  )
  on conflict(key) 
  do nothing
  ;

  insert into app.license_type(
    name
    ,key
    ,application_id
  )
  values
  (
    'Product Packaging'
    ,'trc-product-processing'
    ,(select id from app.application where key = 'trc-product-processing')
  )
  on conflict(key) 
  do nothing
  ;

  insert into app.license(
    app_tenant_id
    ,license_type_id
    ,name
    ,assigned_to_app_user_id
  )
  select
    au.app_tenant_id
    ,(select id from app.license_type where key = 'trc-product-processing')
    ,au.username || ' - ' || (select name from app.license_type where key = 'trc-product-processing')
    ,au.id
  from auth.app_user au
  where au.permission_key in ('SuperAdmin', 'Admin', 'User')
  on conflict (assigned_to_app_user_id, license_type_id)
  do nothing
  ;

--------------------------------------------------   product packaging
  insert into app.application(
    name 
    ,key
  ) 
  values (
    'Product Processing'
    ,'trc-product-packaging'
  )
  on conflict(key) 
  do nothing
  ;

  insert into app.license_type(
    name
    ,key
    ,application_id
  )
  values
  (
    'Product Processing'
    ,'trc-product-packaging'
    ,(select id from app.application where key = 'trc-product-packaging')
  )
  on conflict(key) 
  do nothing
  ;

  insert into app.license(
    app_tenant_id
    ,license_type_id
    ,name
    ,assigned_to_app_user_id
  )
  select
    au.app_tenant_id
    ,(select id from app.license_type where key = 'trc-product-packaging')
    ,au.username || ' - ' || (select name from app.license_type where key = 'trc-product-packaging')
    ,au.id
  from auth.app_user au
  where au.permission_key in ('SuperAdmin', 'Admin', 'User')
  on conflict (assigned_to_app_user_id, license_type_id)
  do nothing
  ;

COMMIT;

