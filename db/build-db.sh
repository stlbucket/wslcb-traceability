#!/usr/bin/env bash
set -e
source config.sh

dropdb -U $DB_USER -h $DB_HOST $DB_NAME || true
createdb -U $DB_USER -h $DB_HOST $DB_NAME
./scripts/structure/build-db-structure.sh
./scripts/functions/build-db-functions.sh