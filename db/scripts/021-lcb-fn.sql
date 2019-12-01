drop schema if exists lcb_fn cascade;
create schema lcb_fn;
grant usage on schema lcb_fn to app_user;
grant usage on schema util_fn to app_user;

CREATE OR REPLACE FUNCTION lcb_fn.obtain_ids(
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
      app_tenant_id,
      lcb_license_holder_id,
      id_origin,
      reporting_status,
      inventory_type
    )
    SELECT
      _current_app_user.app_tenant_id,
      _lcb_license_holder_id,
      'WSLCB',
      'PROVISIONED',
      _inventory_type
    FROM
      generate_series(1, _number_requested)
    RETURNING *
    ;
  end;
  $$;
ALTER FUNCTION lcb_fn.obtain_ids(text,integer) OWNER TO app;


create type lcb_fn.report_inventory_lot_input as (
  id text,
  licensee_identifier text,
  inventory_type text,
  description text,
  quantity numeric(10,2),
  units text,
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

      -- make sure this lot can be identified later
      if _inventory_lot_input.id is null or _inventory_lot_input.id = '' then
        if _inventory_lot_input.licensee_identifier is null or _inventory_lot_input.licensee_identifier = '' then
          raise exception 'illegal operation - batch cancelled:  all inventory lots must have id OR licensee_identifier defined.';
        end if;
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
          licensee_identifier,
          app_tenant_id,
          lcb_license_holder_id,
          id_origin,
          reporting_status,
          inventory_type,
          description,
          quantity,
          units,
          strain_name,
          area_identifier
        )
        SELECT
          COALESCE(_inventory_lot_input.id, util_fn.generate_ulid()),
          _inventory_lot_input.licensee_identifier,
          _current_app_user.app_tenant_id,
          _lcb_license_holder_id,
          case when _inventory_lot_input.id is null then 'WSLCB' else 'LICENSEE' end,
          'ACTIVE',
          _inventory_lot_input.inventory_type,
          _inventory_lot_input.description,
          _inventory_lot_input.quantity,
          _inventory_lot_input.units,
          _inventory_lot_input.strain_name,
          _inventory_lot_input.area_identifier
        RETURNING * INTO _inventory_lot;
      else
        if _inventory_lot_input.inventory_type != _inventory_lot.inventory_type then
          raise exception 'illegal operation - batch cancelled:  cannot change inventory type of an existing inventory lot: %', _inventory_lot.id;
        end if;

        update lcb.inventory_lot set
          licensee_identifier = _inventory_lot_input.licensee_identifier,
          description = _inventory_lot_input.description,
          quantity = _inventory_lot_input.quantity,
          units = _inventory_lot_input.units,
          strain_name = _inventory_lot_input.strain_name,
          area_identifier = _inventory_lot_input.area_identifier,
          reporting_status = 'ACTIVE'
        where id = _inventory_lot_id
        and (
          _inventory_lot_input.licensee_identifier != licensee_identifier
          OR _inventory_lot_input.description != description
          OR _inventory_lot_input.quantity != quantity
          OR _inventory_lot_input.units != units
          OR _inventory_lot_input.strain_name != strain_name
          OR _inventory_lot_input.area_identifier != area_identifier
        )
        ;

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
      reporting_status = 'DESTROYED'
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
      reporting_status = 'DEPLETED'
    where id = ANY(_ids);

    RETURN QUERY SELECT * FROM lcb.inventory_lot WHERE id = ANY(_ids);
  END;
  $$;


