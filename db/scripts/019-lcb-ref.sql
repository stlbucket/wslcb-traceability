create schema if not exists lcb_ref;
grant usage on schema lcb_ref to app_user;


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
  ('BF', 'Bulk Flower', 'g'),
  ('UM', 'Usable Marijuana', 'g'),
  ('PM', 'Packaged Marijuana', 'g'),
  ('PR', 'Pre-roll Joints', 'ct'),
  ('CL', 'Clones', 'ct'),
  ('SD', 'Seeds', 'ct'),
  ('IS', 'Infused Solid Edible', 'ct'),
  ('IL', 'Infused Liquid Edible', 'ct')
;

CREATE TABLE lcb_ref.inventory_lot_reporting_status (
    id text NOT NULL UNIQUE,
    CONSTRAINT ck_inventory_lot_reporting_status_id CHECK ((id <> ''::text))
);

ALTER TABLE lcb_ref.inventory_lot_reporting_status OWNER TO app;
ALTER TABLE ONLY lcb_ref.inventory_lot_reporting_status
    ADD CONSTRAINT inventory_lot_reporting_status PRIMARY KEY (id);

INSERT INTO lcb_ref.inventory_lot_reporting_status(id)
values
  ('PROVISIONED'),
  ('INVALIDATED'),
  ('ACTIVE'),
  ('DESTROYED'),
  ('DEPLETED')
;

