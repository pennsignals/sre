#!/usr/bin/env bash
set -euxo pipefail

c="10.145.243"

octets=("4")
jumps=($(printf "${c}.%s " "${octets[@]}"))
unset octets
unset c

postgres_database="datascience"
postgres_host="use2-ds-ruby.postgres.database.azure.com"
postgres_port="5432"
postgres_username="datascience"
