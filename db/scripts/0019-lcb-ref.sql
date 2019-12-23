drop schema if exists lcb_ref cascade;

create schema if not exists lcb_ref;
grant usage on schema lcb_ref to app_user;
grant usage on schema lcb_ref to app;


CREATE TABLE lcb_ref.inventory_type (
    id text NOT NULL UNIQUE,
    name text NOT NULL UNIQUE,
    description text NULL,
    units text NOT NULL,
    CONSTRAINT ck_inventory_type_id CHECK ((id <> ''::text))
);
ALTER TABLE lcb_ref.inventory_type OWNER TO app;
ALTER TABLE ONLY lcb_ref.inventory_type
    ADD CONSTRAINT pk_inventory_type PRIMARY KEY (id);

INSERT INTO lcb_ref.inventory_type(id, name, units)
values
  ('WW', 'Waste', 'g'),
  ('WF', 'Wet Flower', 'g'),
  ('BF', 'Bulk Flower', 'g'),
  ('LF', 'Lot Flower', 'g'),
  ('UM', 'Usable Marijuana', 'g'),
  ('PM', 'Packaged Marijuana', 'g'),
  ('PR', 'Pre-roll Joints', 'ct'),
  ('CL', 'Clones', 'ct'),
  ('SD', 'Seeds', 'ct'),
  ('PL', 'Plants', 'ct'),
  ('IS', 'Infused Solid Edible', 'ct'),
  ('IL', 'Infused Liquid Edible', 'ct')
;



CREATE TABLE lcb_ref.conversion_rule (
    id text NOT NULL UNIQUE default util_fn.generate_ulid(),
    from_type_id text NOT NULL,
    to_type_id text NOT NULL
);
ALTER TABLE lcb_ref.conversion_rule OWNER TO app;
ALTER TABLE ONLY lcb_ref.conversion_rule
    ADD CONSTRAINT pk_conversion_rule PRIMARY KEY (id);
ALTER TABLE ONLY lcb_ref.conversion_rule
    ADD CONSTRAINT fk_conversion_rule_from FOREIGN KEY (from_type_id) REFERENCES lcb_ref.inventory_type (id);
ALTER TABLE ONLY lcb_ref.conversion_rule
    ADD CONSTRAINT fk_conversion_rule_to FOREIGN KEY (to_type_id) REFERENCES lcb_ref.inventory_type (id);

insert into lcb_ref.conversion_rule (
  from_type_id,
  to_type_id
)
values
  ('SD', 'CL'),
  ('CL', 'PL'),
  ('PL', 'WF'),
  ('WF', 'BF'),
  ('BF', 'LF'),
  ('LF', 'UM'),
  ('LF', 'PM'),
  ('LF', 'PR'),
  ('LF', 'UM')
;

CREATE TABLE lcb_ref.inventory_lot_reporting_status (
    id text NOT NULL UNIQUE,
    CONSTRAINT ck_inventory_lot_reporting_status_id CHECK ((id <> ''::text))
);

ALTER TABLE lcb_ref.inventory_lot_reporting_status OWNER TO app;
ALTER TABLE ONLY lcb_ref.inventory_lot_reporting_status
    ADD CONSTRAINT fk_inventory_lot_reporting_status PRIMARY KEY (id);

INSERT INTO lcb_ref.inventory_lot_reporting_status(id)
values
  ('PROVISIONED'),
  ('INVALIDATED'),
  ('ACTIVE'),
  ('DESTROYED'),
  ('DEPLETED')
;

CREATE TABLE lcb_ref.manifest_status (
    id text NOT NULL UNIQUE,
    CONSTRAINT ck_manifest_status_id CHECK ((id <> ''::text))
);

ALTER TABLE lcb_ref.manifest_status OWNER TO app;
ALTER TABLE ONLY lcb_ref.manifest_status
    ADD CONSTRAINT fk_manifest_status PRIMARY KEY (id);

INSERT INTO lcb_ref.manifest_status(id)
values
  ('MANIFESTED'),
  ('SCHEDULED'),
  ('IN_TRANSIT'),
  ('DELIVERED'),
  ('RECEIVED'),
  ('CANCELLED')
;


CREATE TABLE lcb_ref.inventory_lot_type (
    id text NOT NULL UNIQUE,
    CONSTRAINT ck_inventory_lot_type_id CHECK ((id <> ''::text))
);

ALTER TABLE lcb_ref.inventory_lot_type OWNER TO app;
ALTER TABLE ONLY lcb_ref.inventory_lot_type
    ADD CONSTRAINT fk_inventory_lot_type PRIMARY KEY (id);

INSERT INTO lcb_ref.inventory_lot_type(id)
values
  ('INVENTORY'),
  ('QA_SAMPLE'),
  ('RT_SAMPLE')
;

CREATE TABLE lcb_ref.lcb_license_holder_status (
    id text NOT NULL UNIQUE,
    CONSTRAINT ck_lcb_license_holder_status_id CHECK ((id <> ''::text))
);

ALTER TABLE lcb_ref.lcb_license_holder_status OWNER TO app;
ALTER TABLE ONLY lcb_ref.lcb_license_holder_status
    ADD CONSTRAINT fk_lcb_license_holder_status PRIMARY KEY (id);

INSERT INTO lcb_ref.lcb_license_holder_status(id)
values
  ('ACTIVE'),
  ('INACTIVE')
;

