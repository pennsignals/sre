#!/usr/bin/env bash
set -euxo pipefail

dc="dc1"
dn="${dc}.signals.uphs.upenn.edu"
days=1825
ca_pem="consul-agent-ca.pem"
cs_pem_key="consul-agent-cs-pem.key"
user="signals"
ssh_key=".ssh/acs_key"

secrets="./secrets/secrets.env"
set +x
source $secrets set
set -x

c="10.145.243"

octets=("36" "37" "38")
consuls=($(printf "${c}.%s " "${octets[@]}"))

octets=("52" "53" "54")
vaults=($(printf "${c}.%s " "${octets[@]}"))

octets=("71" "72" "73")
nomads=($(printf "${c}.%s " "${octets[@]}"))

octets=("20")
haproxies=($(printf "${c}.%s " "${octets[@]}"))

octets=("4")
jumps=($(printf "${c}.%s " "${octets[@]}"))

octets=("68" "69" "70")
minions=($(printf "${c}.%s " "${octets[@]}"))

nodes=("${consuls[@]}" "${vaults[@]}" "${nomads[@]}" "${haproxies[@]}" "${minions[@]}" "${jumps[@]}")
unset octets
unset c

old_consul_version="1.9.17"
consul_version="1.10.11"

old_nomad_version="1.0.18"
nomad_version="1.1.18"

old_vault_version="1.6.0"
vault_version="1.6.7"

old_levant_version="0.2.8"
levant_version="0.3.3"

postgres_database=datascience
postgres_host=use2-ds-production-postgres-a.postgres.database.azure.com
postgres_port=5432
postgres_username=datascience

source lib.sh
