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

consul_ips=("36" "37" "38")
vault_ips=("52" "53" "54")
nomad_ips=("71" "72" "73")
haproxy_ips=("20")
jump_ips=("4")
minion_ips=("68" "69" "70")

all_ips=( "${consul_ips[@]}" "${vault_ips[@]}" "${nomad_ips[@]}" "${haproxy_ips[@]}" "${minion_ips[@]}" "${jump_ips[@]}")

old_consul_version="1.9.4"
consul_version="1.9.17"

old_nomad_version="1.0.4"
nomad_version="1.0.18"

old_vault_version="1.6.0"
vault_version="1.6.7"

source lib.sh
