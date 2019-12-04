drop schema if exists lcb_fn cascade;
create schema lcb_fn;
grant usage on schema lcb_fn to app_user;
grant usage on schema util_fn to app_user;

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
  BEGIN
    _current_app_user := auth_fn.current_app_user();

    -- this is not really correct.  need mechanism to switch between licenses
    select id
    into _lcb_license_holder_id
    from lcb.lcb_license_holder
    where app_tenant_id = _current_app_user.app_tenant_id;

    -- raise exception '%, %', _current_app_user.app_tenant_id, _lcb_license_holder_id;

    RETURN QUERY INSERT INTO lcb.inventory_lot(
      updated_by_app_user_id,
      app_tenant_id,
      lcb_license_holder_id,
      id_origin,
      reporting_status,
      inventory_type,
      lot_type
    )
    SELECT
      _current_app_user.id,
      _current_app_user.app_tenant_id,
      _lcb_license_holder_id,
      'WSLCB',
      'PROVISIONED',
      _inventory_type,
      'INVENTORY'
    FROM
      generate_series(1, _number_requested)
    RETURNING *
    ;
  end;
  $$;
ALTER FUNCTION lcb_fn.provision_inventory_lot_ids(text,integer) OWNER TO app;


create type lcb_fn.report_inventory_lot_input as (
  id text,
  licensee_identifier text,
  inventory_type text,
  description text,
  quantity numeric(10,2),
  strain_name text,
  area_identifier text
);

CREATE OR REPLACE FUNCTION lcb_fn.report_inventory_lot(_input lcb_fn.report_inventory_lot_input[]) 
RETURNS setof lcb.inventory_lot
    LANGUAGE plpgsql STRICT
    AS $$
  DECLARE
    _current_app_user auth.app_user;
    _lcb_license_holder_id text;
    _inventory_lot_input lcb_fn.report_inventory_lot_input;
    _inventory_lot lcb.inventory_lot;
    _inventory_lot_id text;
  BEGIN
    _current_app_user := auth_fn.current_app_user();

    -- this is not really correct.  need mechanism to switch between licenses
    select id
    into _lcb_license_holder_id
    from lcb.lcb_license_holder
    where app_tenant_id = _current_app_user.app_tenant_id;

    foreach _inventory_lot_input in ARRAY _input
    loop

      -- if _inventory_lot_input.id is null or _inventory_lot_input.id = '' then
      --   raise exception 'illegal operation - batch cancelled:  all inventory lots must have id defined.';
      -- end if;

      -- make sure this lot can be identified later
      if _inventory_lot_input.id is null or _inventory_lot_input.id = '' then
        -- if _inventory_lot_input.licensee_identifier is null or _inventory_lot_input.licensee_identifier = '' then
        --   raise exception 'illegal operation - batch cancelled:  all inventory lots must have id OR licensee_identifier defined.';
        -- end if;
        _inventory_lot_id := util_fn.generate_ulid();
      else
        -- _inventory_lot_input.id should be verified as a valid ulid here
        _inventory_lot_id := _inventory_lot_input.id;
      end if;
      
      -- find existing lot if it's there
      select *
      into _inventory_lot
      from lcb.inventory_lot
      where id = _inventory_lot_id;

      if _inventory_lot.id is null then
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
          strain_name,
          area_identifier
        )
        SELECT
          COALESCE(_inventory_lot_input.id, util_fn.generate_ulid()),
          _current_app_user.id,
          _inventory_lot_input.licensee_identifier,
          _current_app_user.app_tenant_id,
          _lcb_license_holder_id,
          case when _inventory_lot_input.id is null then 'WSLCB' else 'LICENSEE' end,
          case when _inventory_lot_input.quantity > 0 then 'ACTIVE' else 'DEPLETED' end,
          _inventory_lot_input.inventory_type::text,
          'INVENTORY',
          _inventory_lot_input.description::text,
          _inventory_lot_input.quantity::numeric(10,2),
          _inventory_lot_input.strain_name::text,
          _inventory_lot_input.area_identifier::text
        RETURNING * INTO _inventory_lot;
      else
        if _inventory_lot.reporting_status != 'ACTIVE' and _inventory_lot.reporting_status != 'PROVISIONED' then
          raise exception 'illegal operation - batch cancelled:  can only report on ACTIVE or PROVISIONED inventory lots: %', _inventory_lot.id;
        end if;

        if _inventory_lot_input.inventory_type != _inventory_lot.inventory_type then
          raise exception 'illegal operation - batch cancelled:  cannot change inventory type of an existing inventory lot: %', _inventory_lot.id;
        end if;

        if coalesce(_inventory_lot_input.licensee_identifier::text, '') != coalesce(_inventory_lot.licensee_identifier, '')
          OR coalesce(_inventory_lot_input.description::text, '')         != coalesce(_inventory_lot.description, '')
          OR coalesce(_inventory_lot_input.quantity::numeric(20,2), -1)   != coalesce(_inventory_lot.quantity, -1)
          OR coalesce(_inventory_lot_input.strain_name::text, '')         != coalesce(_inventory_lot.strain_name, '')
          OR coalesce(_inventory_lot_input.area_identifier::text, '')     != coalesce(_inventory_lot.area_identifier, '')
        then
          update lcb.inventory_lot set
            updated_by_app_user_id = _current_app_user.id,
            licensee_identifier = _inventory_lot_input.licensee_identifier::text,
            description = _inventory_lot_input.description::text,
            quantity = _inventory_lot_input.quantity::numeric(10,2),
            strain_name = _inventory_lot_input.strain_name::text,
            area_identifier = _inventory_lot_input.area_identifier::text,
            reporting_status = case when _inventory_lot_input.quantity::numeric(10,2) > 0 then 'ACTIVE' else 'DEPLETED' end
          where id = _inventory_lot_id
          returning * into _inventory_lot
          ;
        end if;

-- raise exception 'wtf %', _inventory_lot_input.quantity::numeric(10,2);
        SELECT * INTO _inventory_lot FROM lcb.inventory_lot WHERE id = _inventory_lot_id;
      end if;

      return next _inventory_lot;

    end loop;

    RETURN;


  end;
  $$;


CREATE OR REPLACE FUNCTION lcb_fn.invalidate_inventory_lot_ids(_ids text[]) 
RETURNS setof lcb.inventory_lot
    LANGUAGE plpgsql STRICT
    AS $$
  DECLARE
    _current_app_user auth.app_user;
    _lcb_license_holder_id text;
    _inventory_lot_input lcb_fn.report_inventory_lot_input;
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


CREATE OR REPLACE FUNCTION lcb_fn.destroy_inventory_lot_ids(_ids text[])
RETURNS setof lcb.inventory_lot
    LANGUAGE plpgsql STRICT
    AS $$
  DECLARE
    _current_app_user auth.app_user;
    _lcb_license_holder_id text;
    _inventory_lot_input lcb_fn.report_inventory_lot_input;
    _inventory_lot lcb.inventory_lot;
    _inventory_lot_id text;
  BEGIN
    _current_app_user := auth_fn.current_app_user();

    -- only active ids can be locked
    if 0 < (select count(*) from lcb.inventory_lot where id = ANY(_ids) and reporting_status != 'ACTIVE') then
      raise exception 'illegal operation - batch cancelled: only active ids can be destroyed.';
    end if;

    update lcb.inventory_lot set
      reporting_status = 'DESTROYED',
      quantity = 0
    where id = ANY(_ids);

    RETURN QUERY SELECT * FROM lcb.inventory_lot WHERE id = ANY(_ids);
  END;
  $$;


CREATE OR REPLACE FUNCTION lcb_fn.deplete_inventory_lot_ids(_ids text[])
RETURNS setof lcb.inventory_lot
    LANGUAGE plpgsql STRICT
    AS $$
  DECLARE
    _current_app_user auth.app_user;
    _lcb_license_holder_id text;
    _inventory_lot_input lcb_fn.report_inventory_lot_input;
    _inventory_lot lcb.inventory_lot;
    _inventory_lot_id text;
  BEGIN
    _current_app_user := auth_fn.current_app_user();

    -- only active ids can be locked
    if 0 < (select count(*) from lcb.inventory_lot where id = ANY(_ids) and reporting_status != 'ACTIVE') then
      raise exception 'illegal operation - batch cancelled: only active ids can be depleted.';
    end if;

    update lcb.inventory_lot set
      reporting_status = 'DEPLETED',
      quantity = 0
    where id = ANY(_ids);

    RETURN QUERY SELECT * FROM lcb.inventory_lot WHERE id = ANY(_ids);
  END;
  $$;


