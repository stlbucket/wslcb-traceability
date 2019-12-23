drop schema if exists lcb_hist cascade;
drop schema if exists lcb cascade;

create schema lcb;
create schema lcb_hist;

grant usage on schema lcb to app_user;
grant usage on schema lcb_hist to app_user;
grant usage on schema lcb to app;
grant usage on schema lcb_hist to app;

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
    status text NOT NULL,
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
ALTER TABLE ONLY lcb.lcb_license_holder
    ADD CONSTRAINT fk_lcb_license_holder_status FOREIGN KEY (status) REFERENCES lcb_ref.lcb_license_holder_status(id);


CREATE TABLE lcb.batch (
    id text DEFAULT util_fn.generate_ulid() NOT NULL,
    app_tenant_id text NOT NULL,
    created_at timestamptz DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamptz NOT NULL,
    inventory_type text not null,
    name text
);
ALTER TABLE lcb.batch OWNER TO app;
ALTER TABLE ONLY lcb.batch
    ADD CONSTRAINT pk_batch PRIMARY KEY (id);
ALTER TABLE ONLY lcb.batch
    ADD CONSTRAINT fk_batch_app_tenant_id FOREIGN KEY (app_tenant_id) REFERENCES auth.app_tenant (id);
ALTER TABLE ONLY lcb.batch
    ADD CONSTRAINT fk_batch_inventory_type FOREIGN KEY (inventory_type) REFERENCES lcb_ref.inventory_type (id);

CREATE TABLE lcb.inventory_lot (
    id text DEFAULT util_fn.generate_ulid() NOT NULL unique,
    updated_by_app_user_id text NOT NULL,
    licensee_identifier text null,
    app_tenant_id text NOT NULL,
    source_conversion_id text NULL,
    batch_id text NULL,
    lcb_license_holder_id text not null,
    reporting_status text not null,
    created_at timestamptz DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamptz NOT NULL,
    deleted_at timestamptz NULL,
    id_origin text not null,
    inventory_type text not null,
    lot_type text not null,
    description text,
    quantity numeric(10,2),
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
    ADD CONSTRAINT fk_inventory_lot_batch FOREIGN KEY (batch_id) REFERENCES lcb.batch (id);
ALTER TABLE ONLY lcb.inventory_lot
    ADD CONSTRAINT fk_inventory_lot_inventory_type FOREIGN KEY (inventory_type) REFERENCES lcb_ref.inventory_type (id);
ALTER TABLE ONLY lcb.inventory_lot
    ADD CONSTRAINT fk_inventory_lot_reporting_status FOREIGN KEY (reporting_status) REFERENCES lcb_ref.inventory_lot_reporting_status (id);
ALTER TABLE ONLY lcb.inventory_lot
    ADD CONSTRAINT fk_inventory_lot_updated_by_app_user FOREIGN KEY (updated_by_app_user_id) REFERENCES auth.app_user (id);
ALTER TABLE ONLY lcb.inventory_lot
    ADD CONSTRAINT fk_inventory_lot_type FOREIGN KEY (lot_type) REFERENCES lcb_ref.inventory_lot_type (id);

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

CREATE TABLE lcb.conversion (
    id text NOT NULL UNIQUE default util_fn.generate_ulid(),
    created_at timestamptz DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamptz NOT NULL,
    app_tenant_id text NOT NULL
);
ALTER TABLE lcb.conversion OWNER TO app;
ALTER TABLE ONLY lcb.conversion
    ADD CONSTRAINT pk_conversion PRIMARY KEY (id);
ALTER TABLE ONLY lcb.conversion
    ADD CONSTRAINT fk_conversion_app_tenant FOREIGN KEY (app_tenant_id) REFERENCES auth.app_tenant (id);
CREATE FUNCTION lcb.fn_timestamp_update_conversion() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN
    NEW.updated_at = current_timestamp;
    RETURN NEW;
  END; $$;
ALTER FUNCTION lcb.fn_timestamp_update_conversion() OWNER TO app;
CREATE TRIGGER tg_timestamp_update_conversion BEFORE INSERT OR UPDATE ON lcb.conversion FOR EACH ROW EXECUTE PROCEDURE lcb.fn_timestamp_update_conversion();
ALTER TABLE ONLY lcb.inventory_lot
    ADD CONSTRAINT fk_inventory_lot_source_conversion FOREIGN KEY (source_conversion_id) REFERENCES lcb.conversion (id);


-- CREATE TABLE lcb.conversion_result (
--     id text NOT NULL UNIQUE default util_fn.generate_ulid(),
--     created_at timestamptz DEFAULT CURRENT_TIMESTAMP NOT NULL,
--     updated_at timestamptz NOT NULL,
--     app_tenant_id text NOT NULL,
--     conversion_id text NOT NULL,
--     inventory_lot_id text NOT NULL
-- );
-- ALTER TABLE lcb.conversion_result OWNER TO app;
-- ALTER TABLE ONLY lcb.conversion_result
--     ADD CONSTRAINT pk_conversion_result PRIMARY KEY (id);
-- ALTER TABLE ONLY lcb.conversion_result
--     ADD CONSTRAINT fk_conversion_app_tenant FOREIGN KEY (app_tenant_id) REFERENCES auth.app_tenant (id);
-- ALTER TABLE ONLY lcb.conversion_result
--     ADD CONSTRAINT fk_conversion_result_conversion FOREIGN KEY (conversion_id) REFERENCES lcb.conversion (id);
-- ALTER TABLE ONLY lcb.conversion_result
--     ADD CONSTRAINT fk_conversion_result_to_inventory_lot FOREIGN KEY (inventory_lot_id) REFERENCES lcb.inventory_lot (id);
-- CREATE FUNCTION lcb.fn_timestamp_update_conversion_result() RETURNS trigger
--     LANGUAGE plpgsql
--     AS $$
--   BEGIN
--     NEW.updated_at = current_timestamp;
--     RETURN NEW;
--   END; $$;
-- ALTER FUNCTION lcb.fn_timestamp_update_conversion_result() OWNER TO app;
-- CREATE TRIGGER tg_timestamp_update_conversion_result BEFORE INSERT OR UPDATE ON lcb.conversion_result FOR EACH ROW EXECUTE PROCEDURE lcb.fn_timestamp_update_conversion_result();

CREATE TABLE lcb.conversion_source (
    id text NOT NULL UNIQUE default util_fn.generate_ulid(),
    created_at timestamptz DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamptz NOT NULL,
    app_tenant_id text NOT NULL,
    conversion_id text NOT NULL,
    inventory_lot_id text NOT NULL,
    sourced_quantity numeric(10,2) NOT NULL
);
ALTER TABLE lcb.conversion_source OWNER TO app;
ALTER TABLE ONLY lcb.conversion_source
    ADD CONSTRAINT pk_conversion_source PRIMARY KEY (id);
ALTER TABLE ONLY lcb.conversion_source
    ADD CONSTRAINT fk_conversion_app_tenant FOREIGN KEY (app_tenant_id) REFERENCES auth.app_tenant (id);
ALTER TABLE ONLY lcb.conversion_source
    ADD CONSTRAINT fk_conversion_source_conversion FOREIGN KEY (conversion_id) REFERENCES lcb.conversion (id);
ALTER TABLE ONLY lcb.conversion_source
    ADD CONSTRAINT fk_conversion_source_to_inventory_lot FOREIGN KEY (inventory_lot_id) REFERENCES lcb.inventory_lot (id);
CREATE FUNCTION lcb.fn_timestamp_update_conversion_source() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN
    NEW.updated_at = current_timestamp;
    RETURN NEW;
  END; $$;
ALTER FUNCTION lcb.fn_timestamp_update_conversion_source() OWNER TO app;
CREATE TRIGGER tg_timestamp_update_conversion_source BEFORE INSERT OR UPDATE ON lcb.conversion_source FOR EACH ROW EXECUTE PROCEDURE lcb.fn_timestamp_update_conversion_source();


-- CREATE TABLE lcb.possession (
--     id text NOT NULL UNIQUE default util_fn.generate_ulid(),
--     created_at timestamptz DEFAULT CURRENT_TIMESTAMP NOT NULL,
--     updated_at timestamptz NOT NULL,
--     app_tenant_id text NOT NULL,
--     lcb_license_holder_id text not null,
--     inventory_lot_id text NOT NULL,
--     acquisition_date timestamptz NOT NULL DEFAULT current_timestamp,
--     relinquish_date timestamptz NULL
-- );
-- ALTER TABLE lcb.possession OWNER TO app;
-- ALTER TABLE ONLY lcb.possession
--     ADD CONSTRAINT pk_possession PRIMARY KEY (id);
-- ALTER TABLE ONLY lcb.possession
--     ADD CONSTRAINT fk_conversion_app_tenant FOREIGN KEY (app_tenant_id) REFERENCES auth.app_tenant (id);
-- ALTER TABLE ONLY lcb.possession
--     ADD CONSTRAINT fk_possession_lcb_license_holder FOREIGN KEY (lcb_license_holder_id) REFERENCES lcb.lcb_license_holder (id);
-- ALTER TABLE ONLY lcb.possession
--     ADD CONSTRAINT fk_possession_to_inventory_lot FOREIGN KEY (inventory_lot_id) REFERENCES lcb.inventory_lot (id);
-- CREATE FUNCTION lcb.fn_timestamp_update_possession() RETURNS trigger
--     LANGUAGE plpgsql
--     AS $$
--   BEGIN
--     NEW.updated_at = current_timestamp;
--     RETURN NEW;
--   END; $$;
-- ALTER FUNCTION lcb.fn_timestamp_update_possession() OWNER TO app;
-- CREATE TRIGGER tg_timestamp_update_possession BEFORE INSERT OR UPDATE ON lcb.possession FOR EACH ROW EXECUTE PROCEDURE lcb.fn_timestamp_update_possession();


------------------------------------------------------------------------------------------------  lcb_hist
CREATE TABLE lcb_hist.hist_inventory_lot (
    id text DEFAULT util_fn.generate_ulid() NOT NULL unique,
    updated_by_app_user_id text NOT NULL,
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
    lot_type text not null,
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
        updated_by_app_user_id,
        licensee_identifier,
        app_tenant_id,
        lcb_license_holder_id,
        created_at,
        updated_at,
        deleted_at,
        id_origin,
        reporting_status,
        inventory_type,
        lot_type,
        description,
        quantity,
        strain_name,
        area_identifier
    )
    values (
        OLD.id,
        OLD.updated_by_app_user_id,
        OLD.licensee_identifier,
        OLD.app_tenant_id,
        OLD.lcb_license_holder_id,
        OLD.created_at,
        OLD.updated_at,
        OLD.deleted_at,
        OLD.id_origin,
        OLD.reporting_status,
        OLD.inventory_type,
        OLD.lot_type,
        OLD.description,
        OLD.quantity,
        OLD.strain_name,
        OLD.area_identifier
    )
    ;

    RETURN OLD;
  END; $$;
ALTER FUNCTION lcb_hist.fn_capture_hist_inventory_lot() OWNER TO app;
CREATE TRIGGER tg_capture_hist_inventory_lot AFTER UPDATE ON lcb.inventory_lot FOR EACH ROW EXECUTE PROCEDURE lcb_hist.fn_capture_hist_inventory_lot();






