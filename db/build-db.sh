#!/usr/bin/env bash
# dropdb -U postgres -h 0.0.0.0 lcb
# createdb -U postgres -h 0.0.0.0 lcb
# psql -U postgres -h 0.0.0.0 -d lcb -f 005-pg-ulid.sql
# psql -U postgres -h 0.0.0.0 -d lcb -f 010-phile-starter.sql
psql -U postgres -h 0.0.0.0 -d lcb -f 020-lcb.sql
