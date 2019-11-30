create schema if not exists lcb_ref;


CREATE TABLE lcb_ref.inventory_type (
    id text NOT NULL UNIQUE,
    name text NOT NULL UNIQUE,
    description text NULL,
    CONSTRAINT ck_inventory_type_id CHECK ((id <> ''::text))
);

ALTER TABLE lcb_ref.inventory_type OWNER TO app;
ALTER TABLE ONLY lcb_ref.inventory_type
    ADD CONSTRAINT pk_inventory_type PRIMARY KEY (id);

INSERT INTO lcb_ref.inventory_type(id, name)
values
  ('BF', 'Bulk Flower'),
  ('UM', 'Usable Marijuana'),
  ('PM', 'Packaged Marijuana'),
  ('PR', 'Pre-roll Joints'),
  ('CL', 'Clones'),
  ('SD', 'Seeds'),
  ('IS', 'Infused Solid Edible'),
  ('IL', 'Infused Liquid Edible')
;



CREATE TABLE lcb_ref.reporting_status (
    id text NOT NULL UNIQUE,
    CONSTRAINT ck_reporting_status_id CHECK ((id <> ''::text))
);

ALTER TABLE lcb_ref.reporting_status OWNER TO app;
ALTER TABLE ONLY lcb_ref.reporting_status
    ADD CONSTRAINT reporting_status PRIMARY KEY (id);

INSERT INTO lcb_ref.reporting_status(id)
values
  ('PROVISIONED'),
  ('INVALIDATED'),
  ('REPORTED')
;

