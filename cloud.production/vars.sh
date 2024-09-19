#!/usr/bin/env bash
set -euxo pipefail

dc="dc1"
dn="${dc}.signals.uphs.upenn.edu"
days=1825
C="10.145.243"
ca_pem="consul-agent-ca.pem"
cs_pem_key="consul-agent-cs-pem.key"
user="signals"
ssh_key=".ssh/acs_key"

secrets="./secrets/secrets.env"
set +x
source $secrets set
set -x

c=${C}

octets=("36" "37" "38")
consuls=($(printf "${c}.%s " "${octets[@]}"))
consul_ips=${octets}

octets=("52" "53" "54")
vaults=($(printf "${c}.%s " "${octets[@]}"))
vault_ips=${octets}

octets=("71" "72" "73")
nomads=($(printf "${c}.%s " "${octets[@]}"))
nomad_ips=${octets}

octets=("20")
haproxies=($(printf "${c}.%s " "${octets[@]}"))
haproxy_ips=${octets}

octets=("4")
jumps=($(printf "${c}.%s " "${octets[@]}"))
jump_ips=${octets}

octets=("68" "69" "70")
minions=($(printf "${c}.%s " "${octets[@]}"))
minion_ips=${octets}

nodes=("${consuls[@]}" "${vaults[@]}" "${nomads[@]}" "${haproxies[@]}" "${minions[@]}" "${jumps[@]}")
unset octets

all_ips=( "${consul_ips[@]}" "${vault_ips[@]}" "${nomad_ips[@]}" "${haproxy_ips[@]}" "${minion_ips[@]}" "${jump_ips[@]}")

old_consul_version="1.9.4"
consul_version="1.9.17"

old_nomad_version="1.0.4"
nomad_version="1.0.18"

old_vault_version="1.6.0"
vault_version="1.6.7"

postgres_database=datascience
postgres_host=use2-ds-production-postgres-a.postgres.database.azure.com
postgres_port=5432
postgres_username=datascience

source lib.sh
