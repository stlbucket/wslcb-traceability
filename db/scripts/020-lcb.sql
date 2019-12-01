drop schema if exists lcb_hist cascade;
drop schema if exists lcb cascade;

create schema lcb;
create schema lcb_hist;

grant usage on schema lcb to app_user;
grant usage on schema lcb_hist to app_user;

CREATE TABLE lcb.lcb_license (
    id text DEFAULT util_fn.generate_ulid() NOT NULL,
    created_at timestamptz DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamptz NOT NULL,
    code text not null check (code != '') unique,
    CONSTRAINT ck_lcb_license_code CHECK ((code <> ''::text))
);

ALTER TABLE lcb.lcb_license OWNER TO app;
ALTER TABLE ONLY lcb.lcb_license
    ADD CONSTRAINT pk_lcb_license PRIMARY KEY (id);


CREATE TABLE lcb.lcb_license_holder (
    id text DEFAULT util_fn.generate_ulid() NOT NULL,
    app_tenant_id text NOT NULL,
    created_at timestamptz DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamptz NOT NULL,
    lcb_license_id text not null unique,
    organization_id text not null,
    acquisition_date timestamptz not null default CURRENT_TIMESTAMP,
    relinquish_date timestamptz null
);

ALTER TABLE lcb.lcb_license_holder OWNER TO app;
ALTER TABLE ONLY lcb.lcb_license_holder
    ADD CONSTRAINT pk_lcb_license_holder PRIMARY KEY (id);
ALTER TABLE ONLY lcb.lcb_license_holder
    ADD CONSTRAINT fk_lcb_license_holder_app_tenant_id FOREIGN KEY (app_tenant_id) REFERENCES auth.app_tenant (id);
ALTER TABLE ONLY lcb.lcb_license_holder
    ADD CONSTRAINT fk_lcb_license_holder_license FOREIGN KEY (lcb_license_id) REFERENCES lcb.lcb_license(id);
ALTER TABLE ONLY lcb.lcb_license_holder
    ADD CONSTRAINT fk_lcb_license_holder_organization FOREIGN KEY (organization_id) REFERENCES org.organization(id);


CREATE TABLE lcb.inventory_lot (
    id text DEFAULT util_fn.generate_ulid() NOT NULL unique,
    licensee_identifier text null,
    app_tenant_id text NOT NULL,
    lcb_license_holder_id text not null,
    reporting_status text not null,
    created_at timestamptz DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamptz NOT NULL,
    deleted_at timestamptz NULL,
    id_origin text not null,
    inventory_type text not null,
    description text,
    quantity numeric(10,2),
    units text,
    strain_name text,
    area_identifier text,
    CONSTRAINT ck_inventory_lot_id_origin CHECK ((id_origin <> ''::text)),
    CONSTRAINT ck_inventory_lot_inventory_type CHECK ((inventory_type <> ''::text)),
    CONSTRAINT ck_inventory_lot_id CHECK ((id <> ''::text))
);

ALTER TABLE lcb.inventory_lot OWNER TO app;
ALTER TABLE ONLY lcb.inventory_lot
    ADD CONSTRAINT pk_inventory_lot PRIMARY KEY (id);
ALTER TABLE ONLY lcb.inventory_lot
    ADD CONSTRAINT fk_inventory_lot_app_tenant_id FOREIGN KEY (app_tenant_id) REFERENCES auth.app_tenant (id);
ALTER TABLE ONLY lcb.inventory_lot
    ADD CONSTRAINT fk_inventory_lot_lcb_license_holder FOREIGN KEY (lcb_license_holder_id) REFERENCES lcb.lcb_license_holder (id);
ALTER TABLE ONLY lcb.inventory_lot
    ADD CONSTRAINT fk_inventory_lot_inventory_type FOREIGN KEY (inventory_type) REFERENCES lcb_ref.inventory_type (id);
ALTER TABLE ONLY lcb.inventory_lot
    ADD CONSTRAINT fk_inventory_lot_reporting_status FOREIGN KEY (reporting_status) REFERENCES lcb_ref.inventory_lot_reporting_status (id);

CREATE FUNCTION lcb.fn_timestamp_update_lcb_license() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN
    NEW.updated_at = current_timestamp;
    RETURN NEW;
  END; $$;
ALTER FUNCTION lcb.fn_timestamp_update_lcb_license() OWNER TO app;
CREATE TRIGGER tg_timestamp_update_lcb_license BEFORE INSERT OR UPDATE ON lcb.lcb_license FOR EACH ROW EXECUTE PROCEDURE lcb.fn_timestamp_update_lcb_license();

CREATE FUNCTION lcb.fn_timestamp_update_lcb_license_holder() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN
    NEW.updated_at = current_timestamp;
    RETURN NEW;
  END; $$;
ALTER FUNCTION lcb.fn_timestamp_update_lcb_license_holder() OWNER TO app;
CREATE TRIGGER tg_timestamp_update_lcb_license_holder BEFORE INSERT OR UPDATE ON lcb.lcb_license_holder FOR EACH ROW EXECUTE PROCEDURE lcb.fn_timestamp_update_lcb_license_holder();

CREATE FUNCTION lcb.fn_timestamp_update_inventory_lot() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN
    NEW.updated_at = current_timestamp;
    RETURN NEW;
  END; $$;
ALTER FUNCTION lcb.fn_timestamp_update_inventory_lot() OWNER TO app;
CREATE TRIGGER tg_timestamp_update_inventory_lot BEFORE INSERT OR UPDATE ON lcb.inventory_lot FOR EACH ROW EXECUTE PROCEDURE lcb.fn_timestamp_update_inventory_lot();


------------------------------------------------------------------------------------------------  lcb_hist
CREATE TABLE lcb_hist.hist_inventory_lot (
    id text DEFAULT util_fn.generate_ulid() NOT NULL unique,
    licensee_identifier text null,
    inventory_lot_id text not null,
    app_tenant_id text NOT NULL,
    lcb_license_holder_id text not null,
    created_at timestamptz NOT NULL,
    updated_at timestamptz NOT NULL,
    deleted_at timestamptz NULL,
    id_origin text not null,
    reporting_status text not null,
    inventory_type text not null,
    description text,
    quantity numeric(10,2),
    units text,
    strain_name text,
    area_identifier text
);
ALTER TABLE ONLY lcb_hist.hist_inventory_lot
    ADD CONSTRAINT fk_hist_inventory_lot_inventory_lot FOREIGN KEY (inventory_lot_id) REFERENCES lcb.inventory_lot (id);
ALTER TABLE ONLY lcb_hist.hist_inventory_lot
    ADD CONSTRAINT fk_hist_inventory_lot_app_tenant_id FOREIGN KEY (app_tenant_id) REFERENCES auth.app_tenant (id);

CREATE FUNCTION lcb_hist.fn_capture_hist_inventory_lot() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN
    insert into lcb_hist.hist_inventory_lot(
        inventory_lot_id,
        licensee_identifier,
        app_tenant_id,
        lcb_license_holder_id,
        created_at,
        updated_at,
        deleted_at,
        id_origin,
        reporting_status,
        inventory_type,
        description,
        quantity,
        units,
        strain_name,
        area_identifier
    )
    values (
        OLD.id,
        OLD.licensee_identifier,
        OLD.app_tenant_id,
        OLD.lcb_license_holder_id,
        OLD.created_at,
        OLD.updated_at,
        OLD.deleted_at,
        OLD.id_origin,
        OLD.reporting_status,
        OLD.inventory_type,
        OLD.description,
        OLD.quantity,
        OLD.units,
        OLD.strain_name,
        OLD.area_identifier
    )
    ;

    RETURN OLD;
  END; $$;
ALTER FUNCTION lcb_hist.fn_capture_hist_inventory_lot() OWNER TO app;
CREATE TRIGGER tg_capture_hist_inventory_lot AFTER UPDATE ON lcb.inventory_lot FOR EACH ROW EXECUTE PROCEDURE lcb_hist.fn_capture_hist_inventory_lot();






