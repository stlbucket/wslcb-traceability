BEGIN;
    -- create test tenants
    insert into auth.app_tenant(name, identifier)
    select
      lower(id) || '_1'
      ,prefix || '11111'
    from lcb_ref.lcb_license_type
    on conflict (identifier)
    do nothing
    ;
-- ("G"=Producer, "M"=Processor,
-- "J"=Producer/Processor,
-- "R"=Retailer, "L"="QA testing lab,
-- "T"=Tribe, "E"=Co-op,
-- "Z"=Licensed Transporter Service

    -- create test users and admins
    insert into auth.app_user(
      app_tenant_id
      ,username
      ,recovery_email
      ,password_hash
      ,permission_key
    )
    select 
      id
      ,lower(name) || '_admin'
      ,lower(name) || '_admin@blah.blah'
      ,public.crypt('badpassword', public.gen_salt('bf'))
      ,'Admin'
    from auth.app_tenant apt
    where identifier != 'anchor'
    ;

    insert into auth.app_user(
      app_tenant_id
      ,username
      ,recovery_email
      ,password_hash
      ,permission_key
    )
    select 
      id
      ,lower(name) || '_user'
      ,lower(name) || '_user@blah.blah'
      ,public.crypt('badpassword', public.gen_salt('bf'))
      ,'User'
    from auth.app_tenant apt
    where identifier != 'anchor'
    ;

    -- values 
    -- (
    --   (select id from auth.app_tenant where identifier = 'G11111')
    --   ,'lcb_producer_admin'
    --   ,'lcb_producer_admin@blah.blah'
    --   ,public.crypt('badpassword', public.gen_salt('bf'))
    --   ,'Admin'
    -- )
    -- ,(
    --   (select id from auth.app_tenant where identifier = 'G11111')
    --   ,'lcb_producer_user'
    --   ,'lcb_producer_user@blah.blah'
    --   ,public.crypt('badpassword', public.gen_salt('bf'))
    --   ,'User'
    -- )
    -- ,(
    --   (select id from auth.app_tenant where identifier = 'M11111')
    --   ,'lcb_processor_admin'
    --   ,'lcb_processor_admin@blah.blah'
    --   ,public.crypt('badpassword', public.gen_salt('bf'))
    --   ,'Admin'
    -- )
    -- ,(
    --   (select id from auth.app_tenant where identifier = 'M11111')
    --   ,'lcb_processor_user'
    --   ,'lcb_processor_user@blah.blah'
    --   ,public.crypt('badpassword', public.gen_salt('bf'))
    --   ,'User'
    -- )
    -- ,(
    --   (select id from auth.app_tenant where identifier = 'R11111')
    --   ,'lcb_retail_admin'
    --   ,'lcb_retail_admin003@blah.blah'
    --   ,public.crypt('badpassword', public.gen_salt('bf'))
    --   ,'Admin'
    -- )
    -- ,(
    --   (select id from auth.app_tenant where identifier = 'R11111')
    --   ,'lcb_retail_user'
    --   ,'lcb_retail_user@blah.blah'
    --   ,public.crypt('badpassword', public.gen_salt('bf'))
    --   ,'User'
    -- )
    -- ,(
    --   (select id from auth.app_tenant where identifier = 'Q11111')
    --   ,'lcb_qa_lab_admin'
    --   ,'lcb_qa_lab_admin003@blah.blah'
    --   ,public.crypt('badpassword', public.gen_salt('bf'))
    --   ,'Admin'
    -- )
    -- ,(
    --   (select id from auth.app_tenant where identifier = 'Q11111')
    --   ,'lcb_qa_lab_user'
    --   ,'lcb_qa_lab_user@blah.blah'
    --   ,public.crypt('badpassword', public.gen_salt('bf'))
    --   ,'User'
    -- )
    -- on conflict (username)
    -- do nothing
    -- ;

    insert into org.organization(
      app_tenant_id
      ,actual_app_tenant_id
      ,name
      ,external_id
    )
    select
      ten.id
      ,ten.id
      ,ten.name
      ,ten.identifier || '-org'
    from auth.app_tenant ten
    where ten.identifier not like 'anchor%'
    on conflict(actual_app_tenant_id)
    do nothing
    ;

    insert into org.facility(
      app_tenant_id
      ,organization_id
      ,name
    )
    select
      o.app_tenant_id 
      ,o.id
      ,o.name || ' Facility'
    from org.organization o;

    insert into org.contact(
      app_tenant_id
      ,organization_id
      ,first_name
      ,last_name
      ,email
      ,external_id
    )
    select
      au.app_tenant_id
      ,(select id from org.organization where app_tenant_id = au.app_tenant_id)
      ,au.username
      ,'Test'
      ,recovery_email
      ,au.username
    from auth.app_user au
    where au.username != 'appsuperadmin'
    on conflict
    do nothing
    ;

    insert into org.contact_app_user(
      contact_id
      ,app_tenant_id
      ,app_user_id
      ,username
    )
    select
      c.id
      ,au.app_tenant_id
      ,au.id
      ,au.username
    from org.contact c
    join auth.app_user au on au.username = c.external_id
    where au.username != 'appsuperadmin'
    on conflict(username)
    do nothing
    ;

    select name, identifier from auth.app_tenant;
    select username, recovery_email, app_tenant_id from auth.app_user;
    select name, (app_tenant_id is not null) is_app_tenant, app_tenant_id from org.organization;
    select email, app_tenant_id, organization_id from org.contact;
    select * from org.contact_app_user;

-- ROLLBACK;
COMMIT;
