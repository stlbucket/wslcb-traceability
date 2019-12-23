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

--------------------------------------------------   qa manager
  insert into app.application(
    name 
    ,key
  ) 
  values (
    'QA'
    ,'trc-qa'
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
    'QA'
    ,'trc-qa'
    ,(select id from app.application where key = 'trc-qa')
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
    ,(select id from app.license_type where key = 'trc-qa')
    ,au.username || ' - ' || (select name from app.license_type where key = 'trc-qa')
    ,au.id
  from auth.app_user au
  where au.permission_key in ('SuperAdmin', 'Admin', 'User')
  on conflict (assigned_to_app_user_id, license_type_id)
  do nothing
  ;

COMMIT;

