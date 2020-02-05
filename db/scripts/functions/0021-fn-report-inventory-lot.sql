create type lcb_fn.report_inventory_lot_input as (
  id text,
  licensee_identifier text,
  inventory_type text,
  description text,
  quantity numeric(10,2),
  strain_name text,
  area_name text
);

CREATE OR REPLACE FUNCTION lcb_fn.report_inventory_lot(
  _input lcb_fn.report_inventory_lot_input[]
) 
RETURNS setof lcb.inventory_lot
    LANGUAGE plpgsql STRICT
    AS $$
  DECLARE
    _current_app_user auth.app_user;
    _lcb_license_holder_id text;
    _inventory_lot_input lcb_fn.report_inventory_lot_input;
    _inventory_lot lcb.inventory_lot;
    _inventory_lot_id text;
    _strain_id text;
    _area_id text;
    _lcb_inventory_type lcb_ref.inventory_type;
    _wtf boolean;
  BEGIN
    _current_app_user := auth_fn.current_app_user();

    _lcb_license_holder_id := (select lcb_fn.get_currrent_lcb_license_holder_id());

    foreach _inventory_lot_input in ARRAY _input
    loop

      -- make sure this lot can be identified later
      if _inventory_lot_input.id is null or _inventory_lot_input.id = '' then
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

      -- determine the strain id
      if _inventory_lot_input.strain_name::text != '' then
        insert into lcb.strain(
          app_tenant_id,
          lcb_license_holder_id,
          name
        )
        values (
          _current_app_user.app_tenant_id,
          _lcb_license_holder_id,
          _inventory_lot_input.strain_name::text
        )
        on conflict(lcb_license_holder_id, name)
        do update set lcb_license_holder_id = _lcb_license_holder_id
        returning id into _strain_id
        ;
      else
        select null into _strain_id;
      end if;

      -- determine the area id
      if _inventory_lot_input.area_name::text != '' then
        insert into lcb.area(
          app_tenant_id,
          lcb_license_holder_id,
          name
        )
        values (
          _current_app_user.app_tenant_id,
          _lcb_license_holder_id,
          _inventory_lot_input.area_name::text
        )
        on conflict(lcb_license_holder_id, name)
        do update set lcb_license_holder_id = _lcb_license_holder_id
        returning id into _area_id
        ;
      else
        select null into _area_id;
      end if;

      select *
      into _lcb_inventory_type
      from lcb_ref.inventory_type
      where id = _inventory_lot_input.inventory_type::text
      ;

      if _inventory_lot.id is null then
        if _lcb_inventory_type.id is null then
          raise exception 'illegal operation - batch cancelled:  no inventory type: %', _inventory_lot_input.inventory_type;
        end if;

        if _lcb_inventory_type.is_single_lotted AND _inventory_lot_input.quantity != 1 then
          raise exception 'illegal operation - batch cancelled:  single-lotted inventory type lots must have quantity of 1: %', _inventory_lot_input.inventory_type;
        end if;

        if _area_id is null then
          raise exception 'illegal operation - batch cancelled:  new inventory lots much specify area name';
        end if;

        if _strain_id is null then
          if _lcb_inventory_type.is_strain_optional != true then
            raise exception 'illegal operation - batch cancelled:  must specify strain name for inventory type: %', _lcb_inventory_type.id;
          else
            insert into lcb.strain(app_tenant_id, lcb_license_holder_id, name)
            values (_current_app_user.app_tenant_id, _lcb_license_holder_id, '**NO STRAIN**')
            on conflict(lcb_license_holder_id, name)
            do update set lcb_license_holder_id = _lcb_license_holder_id
            returning id into _strain_id
            ;
          end if;
        end if;
-- -- _wtf = (select lcb_fn_axs.wtf());
-- -- raise exception '_wtf: %', _wtf;
-- -- raise exception 'hey: %,  %, %', _current_app_user.id, _inventory_lot_input, _lcb_inventory_type.id;
--         select lcb_fn_axs.insert_inventory_lot(
--             COALESCE(_inventory_lot_input.id, util_fn.generate_ulid()),
--             _current_app_user.app_tenant_id,
--             _lcb_license_holder_id,
--             _lcb_inventory_type.id,
--             case when _inventory_lot_input.quantity::numeric(10,2) > 0 then 'ACTIVE' else 'DEPLETED' end,
--             case when _inventory_lot_input.id is null then 'WSLCB' else 'LICENSEE' end,
--             _area_id,
--             _strain_id,
--             _current_app_user.id,
--             'INVENTORY',
--             _inventory_lot_input.quantity::numeric(10,2),
--             _inventory_lot_input.description::text,
--             _inventory_lot_input.licensee_identifier,
--             coalesce(_inventory_lot_input.id, util_fn.generate_ulid())
--         ) 
--         into _inventory_lot
--         ;
-- raise exception 'wtf %', _inventory_lot;

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
          strain_id,
          area_id
        )
        SELECT
          COALESCE(_inventory_lot_input.id, util_fn.generate_ulid()),
          _current_app_user.id,
          _inventory_lot_input.licensee_identifier,
          _current_app_user.app_tenant_id,
          _lcb_license_holder_id,
          case when _inventory_lot_input.id is null then 'WSLCB' else 'LICENSEE' end,
          case when _inventory_lot_input.quantity::numeric(10,2) > 0 then 'ACTIVE' else 'DEPLETED' end,
          _lcb_inventory_type.id,
          'INVENTORY',
          _inventory_lot_input.description::text,
          _inventory_lot_input.quantity::numeric(10,2),
          _strain_id,
          _area_id
        RETURNING * INTO _inventory_lot;

      else
raise exception 'ad-hoc reporting update logic is not fully implemented';
        if _inventory_lot.reporting_status != 'ACTIVE' and _inventory_lot.reporting_status != 'PROVISIONED' then
          raise exception 'illegal operation - batch cancelled:  can only report on ACTIVE or PROVISIONED inventory lots: %', _inventory_lot.id;
        end if;

        if _inventory_lot_input.inventory_type != _inventory_lot.inventory_type then
          raise exception 'illegal operation - batch cancelled:  cannot change inventory type of an existing inventory lot: %', _inventory_lot.id;
        end if;
raise exception 'wtf: %, %, %, %', _strain_id, _inventory_lot.strain_id, coalesce(_strain_id, _inventory_lot.strain_id), (coalesce(_strain_id, _inventory_lot.strain_id) != _inventory_lot.strain_id);
        if coalesce(_inventory_lot_input.licensee_identifier::text, _inventory_lot.licensee_identifier)   != _inventory_lot.licensee_identifier
          OR coalesce(_inventory_lot_input.description::text, _inventory_lot.description)                 != _inventory_lot.description
          OR coalesce(_inventory_lot_input.quantity::numeric(20,2), _inventory_lot.quantity)              != _inventory_lot.quantity
          OR coalesce(_strain_id, _inventory_lot.strain_id)                                               != _inventory_lot.strain_id
          OR coalesce(_area_id, _inventory_lot.area_id)                                                   != _inventory_lot.area_id
        then
raise exception 'yo bitch';
          update lcb.inventory_lot set
            updated_by_app_user_id = _current_app_user.id,
            licensee_identifier = coalesce(_inventory_lot_input.licensee_identifier::text, licensee_identifier),
            description = coalesce(_inventory_lot_input.description::text, description),
            quantity = coalesce(_inventory_lot_input.quantity::numeric(10,2), quantity),
            strain_id = coalesce(_strain_id, strain_id),
            area_id = coalesce(_area_id, area_id),
            reporting_status = case when coalesce(_inventory_lot_input.quantity::numeric(10,2), quantity)::numeric(10,2) > 0 then 'ACTIVE' else 'DEPLETED' end
          where id = _inventory_lot_id
          returning * into _inventory_lot
          ;
        end if;

raise exception 'wtf %', _inventory_lot_input.quantity::numeric(10,2);
        SELECT * INTO _inventory_lot FROM lcb.inventory_lot WHERE id = _inventory_lot_id;
      end if;

      return next _inventory_lot;

    end loop;

    RETURN;


  end;
  $$;

