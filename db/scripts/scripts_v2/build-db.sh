#!/usr/bin/env bash
dropdb -U app -h 0.0.0.0 lcb
createdb -U app -h 0.0.0.0 lcb
psql -U app -h 0.0.0.0 -d lcb -f scripts/0010-phile-starter-schema.sql
psql -U app -h 0.0.0.0 -d lcb -f scripts/019-lcb-ref.sql
psql -U app -h 0.0.0.0 -d lcb -f scripts/020-lcb.sql
psql -U app -h 0.0.0.0 -d lcb -f scripts/021-lcb-fn.sql

psql -U app -h 0.0.0.0 -d lcb -f scripts/9500-security-function.sql
psql -U app -h 0.0.0.0 -d lcb -f scripts/9700-security-table.sql

pg_dump -U app -h 0.0.0.0 lcb > lcb_setup_no_data.sql