#!/usr/bin/env bash
dropdb -U postgres -h 0.0.0.0 lcb
createdb -U postgres -h 0.0.0.0 lcb
./scripts/structure/build-db-structure.sh
./scripts/functions/build-db-functions.sh