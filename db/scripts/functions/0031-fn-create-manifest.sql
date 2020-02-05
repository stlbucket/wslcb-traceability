CREATE OR REPLACE FUNCTION lcb_fn.create_manifest(
  _to_lcb_license_holder_id text,
  _scheduled_transfer_date timestamptz,
  _inventory_lot_ids text[]
) 
RETURNS lcb.manifest
    LANGUAGE plpgsql STRICT
    AS $$
  DECLARE
    _current_app_user auth.app_user;
    _lcb_license_holder_id text;
    _manifest lcb.manifest;
    _manifest_item lcb.manifest_item;
    _inventory_lot_id text;
  BEGIN
    _current_app_user := auth_fn.current_app_user();

    _lcb_license_holder_id := (select lcb_fn.get_currrent_lcb_license_holder_id());

    if (select count(*) from lcb.lcb_license_holder where id = _to_lcb_license_holder_id) != 1 then
        raise exception 'illegal operation - invalid _to_lcb_license_holder_id: %', _to_lcb_license_holder_id;
    end if;

    insert into lcb.manifest(
        app_tenant_id,
        scheduled_transfer_timestamp,
        status,
        status_timestamp,
        from_lcb_license_holder_id,
        to_lcb_license_holder_id        
    )
    values (
        _current_app_user.app_tenant_id,
        _scheduled_transfer_date,
        'MANIFESTED',
        current_timestamp,
        _lcb_license_holder_id,
        _to_lcb_license_holder_id
    )
    returning *
    into _manifest;

--raise exception 'wtf';
    -- foreach _inventory_lot_id in ARRAY _inventory_lot_ids
    -- loop
    --     if (select count(*) from lcb.inventory_lot where id = _inventory_lot_id and _app_tenant_id = _current_app_user.app_tenant_id) != 1 then
    --         raise exception 'illegal operation - invalid _inventory_lot_id: %', _inventory_lot_id;
    --     end if;

    --     select mi.* 
    --     into _manifest_item
    --     from lcb.manifest m
    --     join lcb.manifest_item mi on m.id = mi.manifest_id
    --     join lcb.lcb_license_holder lh on lh.id = m._lcb_license_holder_id
    --     where lh.id = _lcb_license_holder_id 
    --     and m.status not in ('RECEIVED', 'CANCELLED')
    --     and mi.manifested_inventory_lot = _inventory_lot_id
    --     ;

    --     if _manifest_item.id is not null then
    --         raise exception 'illegal operation - inventory_lot_id: %  is currently associated with manifest_item_id: %  on manifest_id: %', _inventory_lot_id, _manifest_item.id, _manifest.id;
    --     end if;

    --     insert into lcb.manifest_item(
    --         manifest_id,
    --         manifested_inventory_lot_id
    --     )
    --     values (
    --         _manifest.id,
    --         _inventory_lot_id
    --     )
    --     returning *
    --     into _manifest_item;

    -- end loop;
    

    return _manifest;

  end;
  $$;
