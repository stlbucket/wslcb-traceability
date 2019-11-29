#!/usr/bin/env bash
docker run -p 3000:8090 --network host --name phst -d phile-starter-api:latest .