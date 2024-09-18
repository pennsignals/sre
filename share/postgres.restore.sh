#! /usr/bin/env bash

source vars.sh
set +x
sudo pg_restore -Fc -f "/nfsdisk/postgres_backups/$(date '%(%Y.%m.%d)')${postgres_database}.dump" "user=${postgres_username} password=${postgres_password} host=${postgres_host} port=${postgres_port} dbname=${postgres_database}"
set -x
