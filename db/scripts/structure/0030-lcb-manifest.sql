drop table if exists lcb.manifest cascade;
drop table if exists lcb.manifest_item cascade;

CREATE TABLE lcb.manifest (
    id text DEFAULT util_fn.generate_ulid() NOT NULL,
    app_tenant_id text NOT NULL,
    -- to_app_tenant_id text NOT NULL,
    created_at timestamptz DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamptz NOT NULL,
    scheduled_transfer_timestamp timestamptz NOT NULL,
    status text NOT NULL,
    status_timestamp timestamptz null,
    from_lcb_license_holder_id text not null,
    to_lcb_license_holder_id text not null
);

ALTER TABLE lcb.manifest OWNER TO app;
ALTER TABLE ONLY lcb.manifest
    ADD CONSTRAINT pk_manifest PRIMARY KEY (id);
ALTER TABLE ONLY lcb.manifest
    ADD CONSTRAINT fk_manifest_app_tenant_id FOREIGN KEY (app_tenant_id) REFERENCES auth.app_tenant (id);
-- ALTER TABLE ONLY lcb.manifest
--     ADD CONSTRAINT fk_manifest_app_tenant_id FOREIGN KEY (to_app_tenant_id) REFERENCES auth.app_tenant (id);
ALTER TABLE ONLY lcb.manifest
    ADD CONSTRAINT fk_manifest_from_lcb_license_holder FOREIGN KEY (from_lcb_license_holder_id) REFERENCES lcb.lcb_license_holder(id);
ALTER TABLE ONLY lcb.manifest
    ADD CONSTRAINT fk_manifest_to_lcb_license_holder FOREIGN KEY (to_lcb_license_holder_id) REFERENCES lcb.lcb_license_holder(id);
ALTER TABLE ONLY lcb.manifest
    ADD CONSTRAINT fk_manifest_status FOREIGN KEY (status) REFERENCES lcb_ref.manifest_status(id);


CREATE OR REPLACE FUNCTION lcb.fn_timestamp_update_manifest() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN
    NEW.updated_at = current_timestamp;
    RETURN NEW;
  END; $$;
ALTER FUNCTION lcb.fn_timestamp_update_manifest() OWNER TO app;
CREATE TRIGGER tg_timestamp_update_manifest BEFORE INSERT OR UPDATE ON lcb.manifest FOR EACH ROW EXECUTE PROCEDURE lcb.fn_timestamp_update_manifest();


CREATE TABLE lcb.manifest_item (
    id text DEFAULT util_fn.generate_ulid() NOT NULL,
    app_tenant_id text NOT NULL,
    -- to_app_tenant_id text NOT NULL,
    created_at timestamptz DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamptz NOT NULL,
    manifest_id text NOT NULL,
    manifested_inventory_lot_id text NOT NULL,
    transferred_hist_inventory_lot_id text NULL
);

ALTER TABLE lcb.manifest_item OWNER TO app;
ALTER TABLE ONLY lcb.manifest_item
    ADD CONSTRAINT pk_manifest_item PRIMARY KEY (id);
ALTER TABLE ONLY lcb.manifest_item
    ADD CONSTRAINT fk_manifest_item_app_tenant_id FOREIGN KEY (app_tenant_id) REFERENCES auth.app_tenant (id);
-- ALTER TABLE ONLY lcb.manifest_item
--     ADD CONSTRAINT fk_manifest_item_app_tenant_id FOREIGN KEY (to_app_tenant_id) REFERENCES auth.app_tenant (id);
ALTER TABLE ONLY lcb.manifest_item
    ADD CONSTRAINT fk_manifest_item_manifest FOREIGN KEY (manifest_id) REFERENCES lcb.manifest(id);
ALTER TABLE ONLY lcb.manifest_item
    ADD CONSTRAINT fk_manifest_item_manifested_inventory_lot FOREIGN KEY (manifested_inventory_lot_id) REFERENCES lcb.inventory_lot(id);
ALTER TABLE ONLY lcb.manifest_item
    ADD CONSTRAINT fk_manifest_item_transferred_inventory_lot FOREIGN KEY (transferred_hist_inventory_lot_id) REFERENCES lcb_hist.hist_inventory_lot(id);


CREATE OR REPLACE FUNCTION lcb.fn_timestamp_update_manifest_item() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN
    NEW.updated_at = current_timestamp;
    RETURN NEW;
  END; $$;
ALTER FUNCTION lcb.fn_timestamp_update_manifest_item() OWNER TO app;
CREATE TRIGGER tg_timestamp_update_manifest_item BEFORE INSERT OR UPDATE ON lcb.manifest_item FOR EACH ROW EXECUTE PROCEDURE lcb.fn_timestamp_update_manifest_item();

