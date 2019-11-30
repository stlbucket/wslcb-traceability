#!/usr/bin/env bash
psql -U postgres -h 0.0.0.0 -d lcb -f data/1000-tenants.sql
psql -U postgres -h 0.0.0.0 -d lcb -f data/1100-address-book.sql
psql -U postgres -h 0.0.0.0 -d lcb -f data/1200-lcb-traceability.sql
psql -U postgres -h 0.0.0.0 -d lcb -f data/1500-applications.sql

pg_dump -U postgres -h 0.0.0.0 lcb > lcb_setup_with_data.sql