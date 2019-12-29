#!/usr/bin/env bash
dropdb -U postgres -h 0.0.0.0 lcb
createdb -U postgres -h 0.0.0.0 lcb
psql -U postgres -h 0.0.0.0 -d lcb -f scripts/0001-roles.sql
psql -U postgres -h 0.0.0.0 -d lcb -f scripts/0005-extensions.sql
psql -U postgres -h 0.0.0.0 -d lcb -f scripts/0010-phile-starter-schema.sql
psql -U postgres -h 0.0.0.0 -d lcb -f scripts/0015-anchor-tenant.sql
psql -U postgres -h 0.0.0.0 -d lcb -f scripts/0019-lcb-ref.sql
psql -U postgres -h 0.0.0.0 -d lcb -f scripts/0020-lcb-inventory-lot.sql
psql -U postgres -h 0.0.0.0 -d lcb -f scripts/0021-lcb-inventory-lot-fn.sql
psql -U postgres -h 0.0.0.0 -d lcb -f scripts/0021-lcb-inventory-lot-fn.sql
psql -U postgres -h 0.0.0.0 -d lcb -f scripts/0022-fn-sublot.sql
psql -U postgres -h 0.0.0.0 -d lcb -f scripts/0023-fn-convert.sql
psql -U postgres -h 0.0.0.0 -d lcb -f scripts/0025-fn-qa-sample-inventory.sql
psql -U postgres -h 0.0.0.0 -d lcb -f scripts/0026-fn-rt-sample-inventory.sql
psql -U postgres -h 0.0.0.0 -d lcb -f scripts/0027-fn-strain-inventory-type-lot-counts.sql
psql -U postgres -h 0.0.0.0 -d lcb -f scripts/0030-lcb-manifest.sql
psql -U postgres -h 0.0.0.0 -d lcb -f scripts/0031-fn-create-manifest.sql
psql -U postgres -h 0.0.0.0 -d lcb -f scripts/0040-lcb-qa-results.sql

psql -U postgres -h 0.0.0.0 -d lcb -f scripts/9500-security-function.sql
psql -U postgres -h 0.0.0.0 -d lcb -f scripts/9700-security-table.sql

# pg_dump -U postgres -h 0.0.0.0 lcb > lcb_setup_no_data.sql