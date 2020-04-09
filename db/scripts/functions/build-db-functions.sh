#!/usr/bin/env bash
set -e
source config.sh

psql -U postgres -h $DB_HOST -d $DB_NAME -f scripts/functions/axs/0010-lcb-fn-axs-schema.sql
psql -U postgres -h $DB_HOST -d $DB_NAME -f scripts/functions/axs/0018-fn-insert-inventory-lot.sql

psql -U postgres -h $DB_HOST -d $DB_NAME -f scripts/functions/0010-lcb-fn-schema.sql
psql -U postgres -h $DB_HOST -d $DB_NAME -f scripts/functions/0011-fn-get-lcb-license-holder-id.sql
psql -U postgres -h $DB_HOST -d $DB_NAME -f scripts/functions/0015-fn-provision-inventory-lot.sql
psql -U postgres -h $DB_HOST -d $DB_NAME -f scripts/functions/0021-fn-report-inventory-lot.sql
psql -U postgres -h $DB_HOST -d $DB_NAME -f scripts/functions/0022-fn-sublot.sql
psql -U postgres -h $DB_HOST -d $DB_NAME -f scripts/functions/0024-fn-convert.sql
psql -U postgres -h $DB_HOST -d $DB_NAME -f scripts/functions/0025-fn-qa-sample-inventory.sql
psql -U postgres -h $DB_HOST -d $DB_NAME -f scripts/functions/0026-fn-rt-sample-inventory.sql
psql -U postgres -h $DB_HOST -d $DB_NAME -f scripts/functions/0027-fn-strain-inventory-type-lot-counts.sql
psql -U postgres -h $DB_HOST -d $DB_NAME -f scripts/functions/0031-fn-create-manifest.sql
psql -U postgres -h $DB_HOST -d $DB_NAME -f scripts/functions/0040-fn-invalidate-inventory.sql
psql -U postgres -h $DB_HOST -d $DB_NAME -f scripts/functions/0050-fn-deplete-inventory.sql
psql -U postgres -h $DB_HOST -d $DB_NAME -f scripts/functions/0060-fn-destroy-inventory.sql
psql -U postgres -h $DB_HOST -d $DB_NAME -f scripts/functions/9500-security-function.sql
