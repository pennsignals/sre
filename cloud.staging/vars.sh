#!/usr/bin/env bash
set -euxo pipefail

subscription="DATASCIENCE-PRODUCTION"
resource_group="use2-uphs-pennsignals-ds-prod-rg"

dc="dc1"
dn="${dc}.signals.uphs.upenn.edu"
days=1825
ca_pem="consul-agent-ca.pem"
cs_pem_key="consul-agent-cs-pem.key"
user="signals"
ssh_key=".ssh/acs_key"

sub="staging"
domain="signals.uphs.upenn.edu"

secrets="./secrets/secrets.env"
set +x
source $secrets set
set -x

c="10.145.241"

octets=("36" "37" "38")
consuls=($(printf "${c}.%s " "${octets[@]}"))

octets=("52" "53" "54")
vaults=($(printf "${c}.%s " "${octets[@]}"))

octets=("68" "69" "70")
nomads=($(printf "${c}.%s " "${octets[@]}"))

octets=("20")
haproxies=($(printf "${c}.%s " "${octets[@]}"))

octets=("4")
jumps=($(printf "${c}.%s " "${octets[@]}"))

octets=("71" "72" "73")
minions=($(printf "${c}.%s " "${octets[@]}"))

nodes=("${consuls[@]}" "${vaults[@]}" "${nomads[@]}" "${haproxies[@]}" "${minions[@]}" "${jumps[@]}")
unset octets
unset c

# consul_version="1.9.17"
# consul_version="1.10.11"
# consul_version="1.11.11"
# consul_version="1.12.9"
# consul_version="1.13.9"
# consul_version="1.14.11"
# consul_version="1.15.10"
# consul_version="1.16.6"
# consul_version="1.17.3"
# consul_version="1.18.2"
consul_version="1.19.2"

consul_template_version="0.39.1"

falcon_sensor_version="7.19.0-17221"
falcon_sensor_cid="EB648EE3E2ED4C688A4615C987F4EAEB-BF"

# nomad_version="1.0.18"
# nomad_version="1.1.18"
# nomad_version="1.2.16"  # raft protocol update to v3 means that nomad server need time to sync
# nomad_version="1.3.16"
# nomad_version="1.4.14"
# nomad_version="1.5.17"
# nomad_version="1.6.10"
# nomad_version="1.7.7"
nomad_version="1.8.4"

# vault_version="1.7.10"
# vault_version="1.8.8"
# vault_version="1.9.3"
# vault_version="1.10.11"
# vault_version="1.11.12"
# vault_version="1.12.11"
# vault_version="1.13.13"
# vault_version="1.14.10"
# vault_version="1.15.6"
# vault_version="1.16.3"
vault_version="1.17.6"

# levant_version="0.2.8"
levant_version="0.3.3"

# postgres_database="datascience"
# postgres_host="use2-ds-production-postgres-b.postgres.database.azure.com"
# postgres_port="5432"
# postgres_username="datascience"

postgres_database="datascience"
postgres_host="use2-ds-opal.postgres.database.azure.com"
postgres_port="5432"
postgres_username="datascience"

source lib.sh
