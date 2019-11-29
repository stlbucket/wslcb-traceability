drop schema if exists lcb_hist cascade;
drop schema if exists lcb cascade;
drop schema if exists lcb_fn cascade;

create schema lcb;
create schema lcb_fn;
create schema lcb_hist;



CREATE TABLE lcb.lcb_license (
    ulid text DEFAULT util_fn.generate_ulid() NOT NULL,
    created_at timestamptz DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamptz NOT NULL,
    code text not null check (code != ''),
    CONSTRAINT ck_lcb_license_code CHECK ((code <> ''::text))
);

ALTER TABLE lcb.lcb_license OWNER TO postgres;
ALTER TABLE ONLY lcb.lcb_license
    ADD CONSTRAINT pk_lcb_license PRIMARY KEY (ulid);


CREATE TABLE lcb.lcb_license_holder (
    ulid text DEFAULT util_fn.generate_ulid() NOT NULL,
    created_at timestamptz DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamptz NOT NULL,
    lcb_license_ulid text not null,
    organization_ulid text not null,
    acquisition_date timestamptz not null default CURRENT_TIMESTAMP,
    relinquish_date timestamptz null
);

ALTER TABLE lcb.lcb_license_holder OWNER TO postgres;
ALTER TABLE ONLY lcb.lcb_license_holder
    ADD CONSTRAINT pk_lcb_license_holder PRIMARY KEY (ulid);
ALTER TABLE ONLY lcb.lcb_license_holder
    ADD CONSTRAINT fk_lcb_license_holder_license FOREIGN KEY (lcb_license_ulid) REFERENCES lcb.lcb_license(ulid);
ALTER TABLE ONLY lcb.lcb_license_holder
    ADD CONSTRAINT fk_lcb_license_holder_organization FOREIGN KEY (organization_ulid) REFERENCES org.organization(ulid);


CREATE TABLE lcb.inventory_lot (
    ulid text DEFAULT util_fn.generate_ulid() NOT NULL,
    lcb_license_holder_ulid text not null,
    created_at timestamptz DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamptz NOT NULL,
    deleted_at timestamptz NULL,
    ulid_origin text not null,
    inventory_type text not null,
    description text,
    quantity numeric(10,2),
    units text,
    strain_name text,
    area_identifier text,
    CONSTRAINT ck_inventory_lot_ulid_origin CHECK ((ulid_origin <> ''::text)),
    CONSTRAINT ck_inventory_lot_inventory_type CHECK ((inventory_type <> ''::text)),
    CONSTRAINT ck_inventory_lot_ulid CHECK ((ulid <> ''::text))
);

ALTER TABLE lcb.inventory_lot OWNER TO postgres;
ALTER TABLE ONLY lcb.inventory_lot
    ADD CONSTRAINT pk_inventory_lot PRIMARY KEY (ulid);
ALTER TABLE ONLY lcb.inventory_lot
    ADD CONSTRAINT fk_inventory_lot_lcb_license_holder FOREIGN KEY (lcb_license_holder_ulid) REFERENCES lcb.lcb_license_holder (ulid);

CREATE FUNCTION lcb.fn_timestamp_update_lcb_license() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN
    NEW.updated_at = current_timestamp;
    RETURN NEW;
  END; $$;
ALTER FUNCTION lcb.fn_timestamp_update_lcb_license() OWNER TO postgres;
CREATE TRIGGER tg_timestamp_update_lcb_license BEFORE INSERT OR UPDATE ON lcb.lcb_license FOR EACH ROW EXECUTE PROCEDURE lcb.fn_timestamp_update_lcb_license();

CREATE FUNCTION lcb.fn_timestamp_update_lcb_license_holder() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN
    NEW.updated_at = current_timestamp;
    RETURN NEW;
  END; $$;
ALTER FUNCTION lcb.fn_timestamp_update_lcb_license_holder() OWNER TO postgres;
CREATE TRIGGER tg_timestamp_update_lcb_license_holder BEFORE INSERT OR UPDATE ON lcb.lcb_license FOR EACH ROW EXECUTE PROCEDURE lcb.fn_timestamp_update_lcb_license_holder();

CREATE FUNCTION lcb.fn_timestamp_update_inventory_lot() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN
    NEW.updated_at = current_timestamp;
    RETURN NEW;
  END; $$;
ALTER FUNCTION lcb.fn_timestamp_update_inventory_lot() OWNER TO postgres;
CREATE TRIGGER tg_timestamp_update_inventory_lot BEFORE INSERT OR UPDATE ON lcb.inventory_lot FOR EACH ROW EXECUTE PROCEDURE lcb.fn_timestamp_update_inventory_lot();



CREATE FUNCTION lcb_fn.current_lcb_license_holder_id() 
RETURNS uuid
    LANGUAGE plpgsql STRICT
    AS $$
  DECLARE
    _current_app_user_contact org.contact;
    _lcb_license_holder_id uuid;
  BEGIN
    _current_app_user_contact := org_fn.current_app_user_contact();

    _lcb_license_holder_id := (
      select id 
      from lcb.lcb_license_holder
      where organization_id = (
        select organization_id
        from org.contact
        where id = _current_app_user_contact.id
      )
    );

    RETURN _lcb_license_holder_id;
  end;
  $$;


CREATE FUNCTION lcb_fn.obtain_ulids(
  _inventory_type text, 
  _number_requested integer
) 
RETURNS setof lcb.inventory_lot
    LANGUAGE plpgsql STRICT
    AS $$
  DECLARE
    _lcb_license_holder_id uuid;
    _inventory_lot lcb.inventory_lot;
    _created_count integer;
  BEGIN
    _created_count := 0;
    _lcb_license_holder_id := lcb_fn.current_lcb_license_holder_id();

    LOOP
      -- some computations
      IF _created_count = _number_requested THEN
          EXIT;  -- exit loop
      END IF;

      -- INSERT INTO lcb.inventory_lot(
      --   app_tenant_id,
      --   lcb_license_holder_id,
      --   ulid_origin,
      --   inventory_type
      -- )
      -- VALUES (

      -- )
    END LOOP;

    -- RETURN _app_tenant;
  end;
  $$;


-- create type lcb_fn.report_inventory_lot_input as (
--   ulid text,
--   inventory_type text,
--   description text,
--   quantity numeric(10,2),
--   units text,
--   strain_name text,
--   area_identifier text
-- );

-- CREATE FUNCTION lcb_fn.report_inventory_lot(_report_inventory_lot_input lcb_fn.report_inventory_lot_input[]) 
-- RETURNS setof lcb.inventory_lot
--     LANGUAGE plpgsql STRICT
--     AS $$
--   DECLARE
--     _current_app_user auth.app_user;
--     _lcb_license_holder lcb.lcb_license_holder;
--   BEGIN
--     _current_app_user := auth_fn.current_app_user();

    

--     RETURN _app_tenant;
--   end;
--   $$;


