#!/usr/bin/env bash
set -e
source config.sh

psql -U $DB_USER -h $DB_HOST -d $DB_NAME -f data/1000-tenants.sql
psql -U $DB_USER -h $DB_HOST -d $DB_NAME -f data/1100-address-book.sql
psql -U $DB_USER -h $DB_HOST -d $DB_NAME -f data/1200-traceability.sql
psql -U $DB_USER -h $DB_HOST -d $DB_NAME -f data/1500-applications.sql