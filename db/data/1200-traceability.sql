BEGIN;

  insert into lcb.lcb_license(code, lcb_license_type_id)
  select apt.identifier, llt.id
  from auth.app_tenant apt
  join lcb_ref.lcb_license_type llt on llt.prefix = substring(apt.identifier from 1 for 1)
  where apt.identifier != 'anchor'
  on conflict do nothing
  ;

  with orgs as (
    select
      apt.identifier license_code
      ,o.id org_id
      ,apt.id app_tenant_id
    from auth.app_tenant apt
    join org.organization o on o.actual_app_tenant_id = apt.id
  )
  insert into lcb.lcb_license_holder(lcb_license_id, organization_id, app_tenant_id, status)
  select ll.id, o.org_id, o.app_tenant_id, 'ACTIVE'
  from orgs o
  join lcb.lcb_license ll on o.license_code = ll.code
  on conflict do nothing
  ;

\echo lcb.lcb_license
select * from lcb.lcb_license;
\echo lcb.lcb_license_holder
select * from lcb.lcb_license_holder;

-- rollback;
COMMIT;
