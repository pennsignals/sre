#!/usr/bin/env bash
set -euxo pipefail

dc="dc1"
dn="${dc}.signals.uphs.upenn.edu"
days=1825
C="170.166"
ca_pem="consul-agent-ca.pem"
cs_pem_key="consul-agent-cs-pem.key"
user="signals"
ssh_key=".ssh/id_rsa"

secrets="./secrets/secrets.env"
set +x
source $secrets set
set -x

consul_ips=("23.82" "23.83" "23.84")
vault_ips=("23.85" "23.86" "23.87")
nomad_ips=("23.36" "23.80" "23.81")
haproxy_ips=("25.33" "25.206")
jump_ips=("23.6")
minion_ips=("23.4" "23.5" "23.30" "23.31" "23.32" "23.33" "23.34" "23.35")
mongo_db_ips=("25.33" "25.34" "25.31")
mongo_monitor_ips=("25.32" "25.158")
mongo_backup_ips=("25.35")

mongo_ips=( "${mongo_db_ips[@]}" "${mongo_monitor_ips[@]}" "${mongo_backup_ips[@]}" )

all_ips=( "${consul_ips[@]}" "${vault_ips[@]}" "${nomad_ips[@]}" "${haproxy_ips[@]}" "${minion_ips[@]}" "${mongo_ips[@]}" "${jump_ips[@]}")

old_consul_version="1.6.1"
consul_version="1.6.1"

old_nomad_version="0.9.6"
nomad_version="0.9.6"

old_vault_version="1.2.3"
vault_version="1.2.3"

source lib.sh

function patch () {
        local ip=$1
        ssh -T -i ${ssh_key} "${user}@${ip}" << 'EOF'
set -euxo pipefail

result=0;
sudo yum --security check-update -y -q || result=$?;
(($result == 0)) && exit 0;
(($result != 100)) && echo "Unexpected check-update code: $result" && exit 1;

result=0;
sudo yum --security update -y -q || result=$?;
(($result == 0)) && exit 0;
(($result != 100)) && echo "Unexpected update code: $result" && exit 1;

exit 0;
EOF
}

function vault_unseal () {
      # quoted first EOF does not expand variables
      ssh -T -i ${ssh_key} "${user}@${ip}" << 'EOF'
set -euxo pipefail

read key < /etc/vault.d/vault_unseal_key.txt

vault operator unseal $key
EOF
}
