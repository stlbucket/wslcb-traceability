drop table if exists lcb.transfer cascade;
drop table if exists lcb.transfer_item cascade;

CREATE TABLE lcb.transfer (
    id text DEFAULT util_fn.generate_ulid() NOT NULL,
    app_tenant_id text NOT NULL,
    created_at timestamptz DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamptz NOT NULL,
    status text NOT NULL,
    status_timestamp timestamptz null,
    from_lcb_license_holder_id text not null,
    to_lcb_license_holder_id text not null
);

ALTER TABLE lcb.transfer OWNER TO app;
ALTER TABLE ONLY lcb.transfer
    ADD CONSTRAINT pk_transfer PRIMARY KEY (id);
ALTER TABLE lcb.transfer
    ADD CONSTRAINT uq_transfer UNIQUE (id,app_tenant_id);
ALTER TABLE ONLY lcb.transfer
    ADD CONSTRAINT fk_transfer_app_tenant_id FOREIGN KEY (app_tenant_id) REFERENCES auth.app_tenant (id);
ALTER TABLE ONLY lcb.transfer
    ADD CONSTRAINT fk_transfer_from_lcb_license_holder FOREIGN KEY (from_lcb_license_holder_id) REFERENCES lcb.lcb_license_holder(id);
ALTER TABLE ONLY lcb.transfer
    ADD CONSTRAINT fk_transfer_to_lcb_license_holder FOREIGN KEY (to_lcb_license_holder_id) REFERENCES lcb.lcb_license_holder(id);
ALTER TABLE ONLY lcb.transfer
    ADD CONSTRAINT fk_transfer_status FOREIGN KEY (status) REFERENCES lcb_ref.transfer_status(id);


CREATE OR REPLACE FUNCTION lcb.fn_timestamp_update_transfer() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN
    NEW.updated_at = current_timestamp;
    RETURN NEW;
  END; $$;
ALTER FUNCTION lcb.fn_timestamp_update_transfer() OWNER TO app;
CREATE TRIGGER tg_timestamp_update_transfer BEFORE INSERT OR UPDATE ON lcb.transfer FOR EACH ROW EXECUTE PROCEDURE lcb.fn_timestamp_update_transfer();


CREATE TABLE lcb.transfer_item (
    id text DEFAULT util_fn.generate_ulid() NOT NULL,
    app_tenant_id text NOT NULL,
    created_at timestamptz DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamptz NOT NULL,
    transfer_id text NOT NULL,
    inventory_lot_id text NOT NULL
);

ALTER TABLE lcb.transfer_item OWNER TO app;
ALTER TABLE ONLY lcb.transfer_item
    ADD CONSTRAINT pk_transfer_item PRIMARY KEY (id);
ALTER TABLE ONLY lcb.transfer_item
    ADD CONSTRAINT fk_transfer_item_app_tenant_id FOREIGN KEY (app_tenant_id) REFERENCES auth.app_tenant (id);
ALTER TABLE ONLY lcb.transfer_item
    ADD CONSTRAINT fk_transfer_item_transfer FOREIGN KEY (transfer_id) REFERENCES lcb.transfer(id);
ALTER TABLE ONLY lcb.transfer_item
    ADD CONSTRAINT fk_transfer_item_inventory_lot FOREIGN KEY (inventory_lot_id) REFERENCES lcb.inventory_lot(id);


CREATE OR REPLACE FUNCTION lcb.fn_timestamp_update_transfer_item() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN
    NEW.updated_at = current_timestamp;
    RETURN NEW;
  END; $$;
ALTER FUNCTION lcb.fn_timestamp_update_transfer_item() OWNER TO app;
CREATE TRIGGER tg_timestamp_update_transfer_item BEFORE INSERT OR UPDATE ON lcb.transfer_item FOR EACH ROW EXECUTE PROCEDURE lcb.fn_timestamp_update_transfer_item();
