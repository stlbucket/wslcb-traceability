#!/usr/bin/env bash
psql -U postgres -h 0.0.0.0 -d lcb -f scripts/structure/0001-roles.sql
psql -U postgres -h 0.0.0.0 -d lcb -f scripts/structure/0005-extensions.sql
psql -U postgres -h 0.0.0.0 -d lcb -f scripts/structure/0010-phile-starter-schema.sql
psql -U postgres -h 0.0.0.0 -d lcb -f scripts/structure/0015-anchor-tenant.sql
psql -U postgres -h 0.0.0.0 -d lcb -f scripts/structure/0019-lcb-ref.sql
psql -U postgres -h 0.0.0.0 -d lcb -f scripts/structure/0020-lcb-inventory-lot.sql
psql -U postgres -h 0.0.0.0 -d lcb -f scripts/structure/0030-lcb-manifest.sql
psql -U postgres -h 0.0.0.0 -d lcb -f scripts/structure/0040-lcb-qa-results.sql
psql -U postgres -h 0.0.0.0 -d lcb -f scripts/structure/9700-security-table.sql
