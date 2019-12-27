drop schema if exists lcb_ref cascade;

create schema if not exists lcb_ref;
grant usage on schema lcb_ref to app_user;
grant usage on schema lcb_ref to app;


CREATE TABLE lcb_ref.inventory_type (
    id text NOT NULL UNIQUE,
    name text NOT NULL UNIQUE,
    description text NULL,
    units text NOT NULL,
    is_single_lotted boolean NOT NULL,
    is_strain_mixable boolean NOT NULL,
    is_strain_optional boolean NOT NULL,
    CONSTRAINT ck_inventory_type_id CHECK ((id <> ''::text))
);
ALTER TABLE lcb_ref.inventory_type OWNER TO app;
ALTER TABLE ONLY lcb_ref.inventory_type
    ADD CONSTRAINT pk_inventory_type PRIMARY KEY (id);

INSERT INTO lcb_ref.inventory_type(id, name, units, is_single_lotted, is_strain_mixable, is_strain_optional)
values
  ('SD', 'Seeds', 'ct', false, false, false),
  ('CL', 'Clones', 'ct', true, false, false),
  ('SL', 'Seedlings', 'ct', true, false, false),
  ('PL', 'Plants', 'ct', true, false, false),
  ('WF', 'Wet Flower', 'g', false, false, false),
  ('BF', 'Bulk Flower', 'g', false, false, false),
  ('LF', 'Lot Flower', 'g', false, false, false),
  ('UM', 'Usable Marijuana', 'g', false, true, false),
  ('PM', 'Packaged Marijuana', 'g', false, true, false),
  ('PR', 'Pre-roll Joints', 'ct', false, true, false),
  ('IS', 'Infused Solid Edibles', 'ct', false, true, true),
  ('IL', 'Infused Liquid Edibles', 'ct', false, true, true),
  ('WW', 'Waste', 'g', false, true, true)
;



CREATE TABLE lcb_ref.conversion_rule (
    to_inventory_type_id text NOT NULL UNIQUE,
    name text NOT NULL,
    secondary_resultants text[]
);
ALTER TABLE lcb_ref.conversion_rule OWNER TO app;
ALTER TABLE ONLY lcb_ref.conversion_rule
    ADD CONSTRAINT pk_conversion_rule PRIMARY KEY (to_inventory_type_id);
ALTER TABLE ONLY lcb_ref.conversion_rule
    ADD CONSTRAINT fk_conversion_rule_to_type FOREIGN KEY (to_inventory_type_id) REFERENCES lcb_ref.inventory_type (id);

CREATE TABLE lcb_ref.conversion_rule_source (
    id text NOT NULL UNIQUE default util_fn.generate_ulid(),
    to_inventory_type_id text NOT NULL,
    inventory_type_id text NOT NULL
);
ALTER TABLE lcb_ref.conversion_rule_source OWNER TO app;
ALTER TABLE ONLY lcb_ref.conversion_rule_source
    ADD CONSTRAINT fk_conversion_rule_source_to_type FOREIGN KEY (to_inventory_type_id) REFERENCES lcb_ref.conversion_rule (to_inventory_type_id);
ALTER TABLE ONLY lcb_ref.conversion_rule_source
    ADD CONSTRAINT fk_conversion_rule_source_inventory_type FOREIGN KEY (inventory_type_id) REFERENCES lcb_ref.inventory_type (id);

insert into lcb_ref.conversion_rule (
  to_inventory_type_id,
  name,
  secondary_resultants
)
select
  id,
  name,
  case when id not in ('SD', 'WW') then '{"WW"}' else '{}'::text[] end
from lcb_ref.inventory_type
;

insert into lcb_ref.conversion_rule_source(
  inventory_type_id,
  to_inventory_type_id
)
values
  ('SD','SL'),
  ('SL','PL'),
  ('CL','PL'),
  ('PL','WF'),
  ('WF','BF'),
  ('BF','LF'),
  ('LF','UM'),
  ('LF','PM'),
  ('LF','PR'),
  ('LF','UM')
;

-- insert into lcb_ref.conversion_rule (
--   name,
--   to_inventory_type_id
-- )
-- values
--   ('SD', 'CL'),
--   ('CL', 'PL'),
--   ('PL', 'WF'),
--   ('WF', 'BF'),
--   ('BF', 'LF'),
--   ('LF', 'UM'),
--   ('LF', 'PM'),
--   ('LF', 'PR'),
--   ('LF', 'UM')
-- ;

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
  ('DEPLETED'),
  ('TRANSFERRED')
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

