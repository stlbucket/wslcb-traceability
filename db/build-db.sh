#!/usr/bin/env bash
dropdb -U app -h 0.0.0.0 lcb
createdb -U app -h 0.0.0.0 lcb
psql -U app -h 0.0.0.0 -d lcb -f scripts/0001-roles.sql
psql -U app -h 0.0.0.0 -d lcb -f scripts/0005-extensions.sql
psql -U app -h 0.0.0.0 -d lcb -f scripts/0010-phile-starter-schema.sql
psql -U app -h 0.0.0.0 -d lcb -f scripts/0019-lcb-ref.sql
psql -U app -h 0.0.0.0 -d lcb -f scripts/0020-lcb-inventory-lot.sql
psql -U app -h 0.0.0.0 -d lcb -f scripts/0021-lcb-inventory-lot-fn.sql
psql -U app -h 0.0.0.0 -d lcb -f scripts/0021-lcb-inventory-lot-fn.sql
psql -U app -h 0.0.0.0 -d lcb -f scripts/0022-fn-sublot.sql
psql -U app -h 0.0.0.0 -d lcb -f scripts/0023-fn-convert.sql
psql -U app -h 0.0.0.0 -d lcb -f scripts/0025-fn-qa-sample-inventory.sql
psql -U app -h 0.0.0.0 -d lcb -f scripts/0026-fn-rt-sample-inventory.sql
psql -U app -h 0.0.0.0 -d lcb -f scripts/0030-lcb-transfer.sql
psql -U app -h 0.0.0.0 -d lcb -f scripts/0040-lcb-qa-results.sql

psql -U app -h 0.0.0.0 -d lcb -f scripts/9500-security-function.sql
psql -U app -h 0.0.0.0 -d lcb -f scripts/9700-security-table.sql

# pg_dump -U app -h 0.0.0.0 lcb > lcb_setup_no_data.sql