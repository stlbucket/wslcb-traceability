#!/usr/bin/env bash
dropdb -U postgres -h 0.0.0.0 lcb
createdb -U postgres -h 0.0.0.0 lcb
psql -U postgres -h 0.0.0.0 -d lcb -f scripts/005-pg-ulid.sql
psql -U postgres -h 0.0.0.0 -d lcb -f scripts/010-phile-starter.sql
psql -U postgres -h 0.0.0.0 -d lcb -f scripts/015-anchor-tenant.sql
psql -U postgres -h 0.0.0.0 -d lcb -f scripts/020-lcb.sql
psql -U postgres -h 0.0.0.0 -d lcb -f scripts/021-lcb-fn.sql

psql -U postgres -h 0.0.0.0 -d lcb -f scripts/9500-security-function.sql
psql -U postgres -h 0.0.0.0 -d lcb -f scripts/9700-security-table.sql

pg_dump -U postgres -h 0.0.0.0 lcb > lcb_setup_no_data.sql