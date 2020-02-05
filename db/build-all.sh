#!/usr/bin/env bash
set -e
source config.sh

./build-db.sh
./build-data.sh