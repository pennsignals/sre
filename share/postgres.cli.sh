#! /usr/bin/env bash
set -euxo pipefail

source vars.sh
set +x
psql -Atx --set=sslmode=require "user=${postgres_username} password=${postgres_password} host=${postgres_host} port=${postgres_port} dbname=${postgres_database}"
set -x
