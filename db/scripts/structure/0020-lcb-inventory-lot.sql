drop schema if exists lcb_hist cascade;
drop schema if exists lcb cascade;

create schema lcb;
create schema lcb_hist;

alter schema lcb owner to  app;
alter schema lcb_hist owner to  app;

grant usage on schema lcb to app_user;
grant usage on schema lcb_hist to app_user;
grant usage on schema lcb to app;
grant usage on schema lcb_hist to app;

CREATE TABLE lcb.lcb_license (
    id text DEFAULT util_fn.generate_ulid() NOT NULL,
    created_at timestamptz DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamptz NOT NULL,
    lcb_license_type_id text NOT NULL,
    code text not null check (code != '') unique,
    CONSTRAINT ck_lcb_license_code CHECK ((code <> ''::text))
);

ALTER TABLE lcb.lcb_license OWNER TO app;
ALTER TABLE ONLY lcb.lcb_license
    ADD CONSTRAINT pk_lcb_license PRIMARY KEY (id);
ALTER TABLE ONLY lcb.lcb_license
    ADD CONSTRAINT fk_lcb_license_type FOREIGN KEY (lcb_license_type_id) REFERENCES lcb_ref.lcb_license_type(id);


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
    lcb_license_holder_id text not null,
    name text
);
ALTER TABLE lcb.batch OWNER TO app;
ALTER TABLE ONLY lcb.batch
    ADD CONSTRAINT pk_batch PRIMARY KEY (id);
ALTER TABLE ONLY lcb.batch
    ADD CONSTRAINT fk_batch_app_tenant_id FOREIGN KEY (app_tenant_id) REFERENCES auth.app_tenant (id);
ALTER TABLE ONLY lcb.batch
    ADD CONSTRAINT fk_batch_inventory_type FOREIGN KEY (inventory_type) REFERENCES lcb_ref.inventory_type (id);
ALTER TABLE ONLY lcb.batch
    ADD CONSTRAINT fk_batch_lcb_license_holder FOREIGN KEY (lcb_license_holder_id) REFERENCES lcb.lcb_license_holder (id);
ALTER TABLE ONLY lcb.batch
    ADD CONSTRAINT uq_batch_lcb_license_holder UNIQUE (lcb_license_holder_id, name);

CREATE TABLE lcb.strain (
    id text DEFAULT util_fn.generate_ulid() NOT NULL,
    app_tenant_id text NOT NULL,
    created_at timestamptz DEFAULT CURRENT_TIMESTAMP NOT NULL,
    lcb_license_holder_id text not null,
    name text
);
ALTER TABLE lcb.strain OWNER TO app;
ALTER TABLE ONLY lcb.strain
    ADD CONSTRAINT pk_strain PRIMARY KEY (id);
ALTER TABLE ONLY lcb.strain
    ADD CONSTRAINT fk_strain_app_tenant_id FOREIGN KEY (app_tenant_id) REFERENCES auth.app_tenant (id);
ALTER TABLE ONLY lcb.strain
    ADD CONSTRAINT fk_strain_lcb_license_holder FOREIGN KEY (lcb_license_holder_id) REFERENCES lcb.lcb_license_holder (id);
ALTER TABLE ONLY lcb.strain
    ADD CONSTRAINT uq_strain_lcb_license_holder UNIQUE (lcb_license_holder_id, name);    

CREATE TABLE lcb.area (
    id text DEFAULT util_fn.generate_ulid() NOT NULL,
    app_tenant_id text NOT NULL,
    created_at timestamptz DEFAULT CURRENT_TIMESTAMP NOT NULL,
    lcb_license_holder_id text not null,
    name text
);
ALTER TABLE lcb.area OWNER TO app;
ALTER TABLE ONLY lcb.area
    ADD CONSTRAINT pk_area PRIMARY KEY (id);
ALTER TABLE ONLY lcb.area
    ADD CONSTRAINT fk_area_app_tenant_id FOREIGN KEY (app_tenant_id) REFERENCES auth.app_tenant (id);
ALTER TABLE ONLY lcb.area
    ADD CONSTRAINT fk_area_lcb_license_holder FOREIGN KEY (lcb_license_holder_id) REFERENCES lcb.lcb_license_holder (id);
ALTER TABLE ONLY lcb.area
    ADD CONSTRAINT uq_area_lcb_license_holder UNIQUE (lcb_license_holder_id, name);

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
    strain_id text,
    area_id text,
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
ALTER TABLE ONLY lcb.inventory_lot
    ADD CONSTRAINT fk_inventory_lot_strain FOREIGN KEY (strain_id) REFERENCES lcb.strain (id);
ALTER TABLE ONLY lcb.inventory_lot
    ADD CONSTRAINT fk_inventory_lot_area FOREIGN KEY (area_id) REFERENCES lcb.area (id);

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

CREATE TABLE lcb.recipe (
    id text NOT NULL UNIQUE default util_fn.generate_ulid(),
    created_at timestamptz DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamptz NOT NULL,
    app_tenant_id text NOT NULL,
    conversion_rule_id text NOT NULL,
    name text NOT NULL
);
ALTER TABLE lcb.recipe OWNER TO app;
ALTER TABLE ONLY lcb.recipe
    ADD CONSTRAINT pk_recipe PRIMARY KEY (id);
ALTER TABLE ONLY lcb.recipe
    ADD CONSTRAINT fk_recipe_app_tenant FOREIGN KEY (app_tenant_id) REFERENCES auth.app_tenant (id);
ALTER TABLE ONLY lcb.recipe
    ADD CONSTRAINT fk_recipe_conversion_rule FOREIGN KEY (conversion_rule_id) REFERENCES lcb_ref.conversion_rule (to_inventory_type_id);
CREATE FUNCTION lcb.fn_timestamp_update_recipe() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN
    NEW.updated_at = current_timestamp;
    RETURN NEW;
  END; $$;
ALTER FUNCTION lcb.fn_timestamp_update_recipe() OWNER TO app;
CREATE TRIGGER tg_timestamp_update_recipe BEFORE INSERT OR UPDATE ON lcb.recipe FOR EACH ROW EXECUTE PROCEDURE lcb.fn_timestamp_update_recipe();

-- CREATE TABLE lcb.recipe_source_inventory_type (
--     id text NOT NULL UNIQUE default util_fn.generate_ulid(),
--     created_at timestamptz DEFAULT CURRENT_TIMESTAMP NOT NULL,
--     updated_at timestamptz NOT NULL,
--     app_tenant_id text NOT NULL,
--     recipe_id text NOT NULL,
--     inventory_type_id text NOT NULL
-- );
-- ALTER TABLE lcb.recipe_source_inventory_type OWNER TO app;
-- ALTER TABLE ONLY lcb.recipe_source_inventory_type
--     ADD CONSTRAINT pk_recipe_source_inventory_type PRIMARY KEY (id);
-- ALTER TABLE ONLY lcb.recipe_source_inventory_type
--     ADD CONSTRAINT fk_recipe_source_inventory_type_app_tenant FOREIGN KEY (app_tenant_id) REFERENCES auth.app_tenant (id);
-- ALTER TABLE ONLY lcb.recipe_source_inventory_type
--     ADD CONSTRAINT fk_recipe_source_inventory_type_recipe FOREIGN KEY (recipe_id) REFERENCES lcb.recipe (id);
-- ALTER TABLE ONLY lcb.recipe_source_inventory_type
--     ADD CONSTRAINT fk_recipe_source_inventory_type_inventory_type FOREIGN KEY (inventory_type_id) REFERENCES lcb_ref.inventory_type (id);
-- CREATE FUNCTION lcb.fn_timestamp_update_recipe_source_inventory_type() RETURNS trigger
--     LANGUAGE plpgsql
--     AS $$
--   BEGIN
--     NEW.updated_at = current_timestamp;
--     RETURN NEW;
--   END; $$;
-- ALTER FUNCTION lcb.fn_timestamp_update_recipe_source_inventory_type() OWNER TO app;
-- CREATE TRIGGER tg_timestamp_update_recipe_source_inventory_type BEFORE INSERT OR UPDATE ON lcb.recipe FOR EACH ROW EXECUTE PROCEDURE lcb.fn_timestamp_update_recipe();

-- CREATE TABLE lcb.recipe_target_inventory_type (
--     id text NOT NULL UNIQUE default util_fn.generate_ulid(),
--     created_at timestamptz DEFAULT CURRENT_TIMESTAMP NOT NULL,
--     updated_at timestamptz NOT NULL,
--     app_tenant_id text NOT NULL,
--     recipe_id text NOT NULL,
--     inventory_type_id text NOT NULL
-- );
-- ALTER TABLE lcb.recipe_target_inventory_type OWNER TO app;
-- ALTER TABLE ONLY lcb.recipe_target_inventory_type
--     ADD CONSTRAINT pk_recipe_target_inventory_type PRIMARY KEY (id);
-- ALTER TABLE ONLY lcb.recipe_target_inventory_type
--     ADD CONSTRAINT fk_recipe_target_inventory_type_app_tenant FOREIGN KEY (app_tenant_id) REFERENCES auth.app_tenant (id);
-- ALTER TABLE ONLY lcb.recipe_target_inventory_type
--     ADD CONSTRAINT fk_recipe_target_inventory_type_recipe FOREIGN KEY (recipe_id) REFERENCES lcb.recipe (id);
-- ALTER TABLE ONLY lcb.recipe_target_inventory_type
--     ADD CONSTRAINT fk_recipe_target_inventory_type_inventory_type FOREIGN KEY (inventory_type_id) REFERENCES lcb_ref.inventory_type (id);
-- CREATE FUNCTION lcb.fn_timestamp_update_recipe_target_inventory_type() RETURNS trigger
--     LANGUAGE plpgsql
--     AS $$
--   BEGIN
--     NEW.updated_at = current_timestamp;
--     RETURN NEW;
--   END; $$;
-- ALTER FUNCTION lcb.fn_timestamp_update_recipe_target_inventory_type() OWNER TO app;
-- CREATE TRIGGER tg_timestamp_update_recipe_target_inventory_type BEFORE INSERT OR UPDATE ON lcb.recipe FOR EACH ROW EXECUTE PROCEDURE lcb.fn_timestamp_update_recipe();

CREATE TABLE lcb.conversion (
    id text NOT NULL UNIQUE default util_fn.generate_ulid(),
    created_at timestamptz DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamptz NOT NULL,
    conversion_rule_to_inventory_type_id text NOT NULL,
    recipe_id text NULL,
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
ALTER TABLE ONLY lcb.conversion
    ADD CONSTRAINT fk_conversion_recipe FOREIGN KEY (recipe_id) REFERENCES lcb.recipe (id);
ALTER TABLE ONLY lcb.inventory_lot
    ADD CONSTRAINT fk_inventory_lot_source_conversion FOREIGN KEY (source_conversion_id) REFERENCES lcb.conversion (id);
ALTER TABLE ONLY lcb.conversion
    ADD CONSTRAINT fk_conversion_conversion_rule FOREIGN KEY (conversion_rule_to_inventory_type_id) REFERENCES lcb_ref.conversion_rule (to_inventory_type_id);

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
    strain_id text,
    area_id text
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
        strain_id,
        area_id
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
        OLD.strain_id,
        OLD.area_id
    )
    ;

    RETURN OLD;
  END; $$;
ALTER FUNCTION lcb_hist.fn_capture_hist_inventory_lot() OWNER TO app;
CREATE TRIGGER tg_capture_hist_inventory_lot AFTER UPDATE ON lcb.inventory_lot FOR EACH ROW EXECUTE PROCEDURE lcb_hist.fn_capture_hist_inventory_lot();






