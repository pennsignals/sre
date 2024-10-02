#!/usr/bin/env bash

function remove_passwd_expiration() {
    local user=$1
    ssh -T -i ${ssh_key} "${user}@${ip}" << EOF
set -euxo pipefail
sudo passwd -x -1 ${user}
EOF
}

function add_admin() {
    local ip=$1
    local uid=$2
    local admin="${3:-admin}"
    ssh -tt -i ${ssh_key} "${user}@${ip}" << EOF
set -euxo pipefail
sudo useradd -m -u ${uid} ${admin}
sudo usermod -aG sudo ${admin}
EOF
}

function append_keys() {
    local ip=$1
    local uid=$2
    local admin="${3:-admin}"
    local authorized_keys="../assets/home/${admin}/.ssh/authorized_keys}"
    scp -i ${ssh_key} ${authorized_keys} ${user}@${ip}:/tmp/${authorized_keys}.tmp
    ssh -T -i ${ssh_key} "${user}@${ip}" << EOF
set -euxo pipefail
src="/tmp/authorized_keys.tmp"
dir="/home/${admin}/.ssh"
dst="${dir}/authorized_keys"
sudo mkdir -p "${dir}"
sudo touch dst
lines=$(cat $src)
for key in $lines
do
  if sudo grep -cFxq "${key}" "${dst}"; then
    : #do nothing
  else
    echo "${key}" | sudo tee -a "${dst}" > /dev/null
  fi
done
sudo chmod 700 "${dir}"
sudo chmod 600 "${dst}"
EOF
}

function symlink_version () {
    local ip=$1
    ssh -T -i ${ssh_key} "${user}@${ip}" << EOF
set -euxo pipefail

if [[ -e /usr/local/bin/consul ]]; then
    wget -O "consul-${consul_version}.zip" "https://releases.hashicorp.com/consul/${consul_version}/consul_${consul_version}_linux_amd64.zip"
    sudo unzip -o "consul-${consul_version}.zip"
    sudo mv consul "/usr/local/bin/consul-${consul_version}"
fi;

if [[ -e /usr/local/bin/vault ]]; then
    wget -O "vault-${vault_version}.zip" "https://releases.hashicorp.com/vault/${vault_version}/vault_${vault_version}_linux_amd64.zip"
    sudo unzip -o "vault-${vault_version}.zip"
    sudo mv vault "/usr/local/bin/vault-${vault_version}"
fi;

if [[ -e /usr/local/bin/nomad ]]; then
    wget -O "nomad-${nomad_version}.zip" "https://releases.hashicorp.com/nomad/${nomad_version}/nomad_${nomad_version}_linux_amd64.zip"
    sudo unzip -o "nomad-${nomad_version}.zip"
    sudo mv nomad "/usr/local/bin/nomad-${nomad_version}"
fi;
EOF
}

function symlink_version_fix () {
    local ip=$1
    ssh -T -i ${ssh_key} "${user}@${ip}" << EOF
set -euxo pipefail
if [[ -f /usr/local/bin/consul-1.9.4 ]]; then
    sudo ln -sf /usr/local/bin/consul-1.9.4 /usr/local/bin/consul
fi;
if [[ -f /usr/local/bin/nomad-1.0.4 ]]; then
    sudo ln -sf /usr/local/bin/nomad-1.0.4 /usr/local/bin/nomad
fi;
if [[ -f /usr/local/bin/vault-1.6.0 ]]; then
    sudo ln -sf /usr/local/bin/vault-1.6.0 /usr/local/bin/vault
fi;
if [[ -f /usr/local/bin/levant-1.2.8 ]]; then
    sudo ln -sf /usr/local/bin/levant-1.2.8 /usr/local/bin/levant
fi;
EOF
}

function check () {
    local ip=$1
    ssh -T -i ${ssh_key} "${user}@${ip}" << EOF
sudo ls
EOF
}

function patch () {
    local ip=$1
    ssh -T -i ${ssh_key} "${user}@${ip}" << EOF
set -euxo pipefail
export DEBIAN_FRONTEND=noninteractive
sudo apt-get update && \
sudo apt-get -y upgrade -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" && \
sudo apt-get -y autoremove
EOF
}

function restart () {
    local ip=$1
    ssh -T -i ${ssh_key} "${user}@${ip}" << EOF
nohup sudo reboot &>/dev/null & exit
EOF
}

function deploy_ca_pem () {
    local ip=$1
    scp -i ${ssh_key} ${ca_pem} ${user}@${ip}:~/${ca_pem}
    ssh -T -i ${ssh_key} "${user}@${ip}" << EOF
sudo cp ~/${ca_pem} /etc/consul.d/
sudo cp ~/${ca_pem} /usr/local/share/ca-certificates/${ca_pem}.crt
sudo update-ca-certificates
EOF
}

function copy_pem_and_key () {
    local ip=$1
    local pem=$2
    local key=$3
    scp -i ${ssh_key} ${pem} ${user}@${ip}:~/${pem}
    scp -i ${ssh_key} ${key} ${user}@${ip}:~/${key}
}

function deploy_consul_client ()  {
    local ip=$1
    local name=$2
    local pem="${name}.pem"
    local key="${name}-key.pem"
    deploy_ca_pem $ip
    copy_pem_and_key $ip $pem $key
    ssh -T -i ${ssh_key} "${user}@${ip}" << EOF
sudo cp ~/${pem} /etc/consul.d/consul-client.pem
sudo cp ~/${key} /etc/consul.d/consul-client-key.pem
sudo chown root:root /etc/consul.d/*.pem
sudo systemctl restart consul
EOF
}

function deploy_consul_server () {
    local ip=$1
    local name=$2
    local pem="${name}.pem"
    local key="${name}-key.pem"
    deploy_ca_pem $ip
    copy_pem_and_key $ip $pem $key
    ssh -T -i ${ssh_key} "${user}@${ip}" << EOF
sudo cp ~/${pem} /etc/consul.d/consul-server.pem
sudo cp ~/${key} /etc/consul.d/consul-server-key.pem
sudo chown root:root /etc/consul.d/*.pem
sudo systemctl restart consul
EOF
}

function symlink_version_hashi () {
    local ip=$1
    ssh -T -i ${ssh_key} "${user}@${ip}" << EOF
set -euxo pipefail
if [[ -f /usr/local/bin/consul ]] && [[ ! -e /usr/local/bin/consul-1.9.4 ]]; then
    sudo mv /usr/local/bin/consul /usr/local/bin/consul-1.9.4
    sudo ln -s /usr/local/bin/consul-1.9.4 /usr/local/bin/consul
fi;
if [[ -f /usr/local/bin/nomad ]] && [[ ! -e /usr/local/bin/nomad-1.0.4 ]]; then
    sudo mv /usr/local/bin/nomad /usr/local/bin/nomad-1.0.4
    sudo ln -s /usr/local/bin/nomad-1.0.4 /usr/local/bin/nomad
fi;
if [[ -f /usr/local/bin/vault ]] && [[ ! -e /usr/local/bin/vault-1.6.0 ]]; then
    sudo mv /usr/local/bin/vault /usr/local/bin/vault-1.6.0
    sudo ln -s /usr/local/bin/vault-1.6.0 /usr/local/bin/vault
fi;
if [[ -f /usr/local/bin/levant ]] && [[ ! -e /usr/local/bin/levant-1.2.8 ]]; then
    sudo mv /usr/local/bin/levant /usr/local/bin/levant-1.2.8
    sudo ln -s /usr/local/bin/levant-1.2.8 /usr/local/bin/levant
fi;
EOF
}

function vault_unseal () {
    # quoted first EOF does not expand variables
    local ip=$1
    ssh -T -i ${ssh_key} "${user}@${ip}" << 'EOF'
set -euxo pipefail
CONSUL_HTTP_TOKEN=$(consul kv get service/consul/vault-token)

get_kv() { curl --header "X-Consul-Token: $CONSUL_HTTP_TOKEN" -s "http://127.0.0.1:8500/v1/kv/service/vault/$1?raw"; }

while
    root_token=$(get_kv root-token)
    [[ ${#root_token} -lt 1 ]];
do
    echo "Waiting for Vault root token"
    sleep 1
done

vault operator unseal $(get_kv unseal-key-1)
vault operator unseal $(get_kv unseal-key-2)
vault operator unseal $(get_kv unseal-key-3)
EOF
}

function update_config () {
    local template="$1"
    local src="$2"
    set +x
    base64encoded=$(echo -n "USERNAME:${pat}" | base64)
    sed 's/"auth": ".*"/"auth": "'$base64encoded'"/g' "$template" > "$src"
    set -x
}

function upload_registry_auth () {
    local ip=$1
    local src=$2
    local user=$3
    local name=$4
    local dst=$5
    scp -i ${ssh_key} ${src} ${user}@${ip}:~/${name}
    ssh -T -i ${ssh_key} "${user}@${ip}" << EOF
set -euxo pipefail
sudo mv ~/${name} ${dst}
sudo chown root:root ${dst}
EOF
}

function update_config () {
    local template=$1
    local src=$2
    set +x
    base64encoded=$(echo -n "USERNAME:${pat}" | base64)
    sed 's/"auth": ".*"/"auth": "'$base64encoded'"/g' $template > $src
    set -x
}

function download_consul() {
    local ip=$1
    local src=$2
    local lnk=$3
    local dst=$4
    scp -i ${ssh_key} ${src} ${user}@${ip}:~/${src}
    ssh -T -i ${ssh_key} "${user}@${ip}" << EOF
set -euxo pipefail
if [[ -e ${lnk} ]]; then
    sudo cp --no-clobber ${src} ${dst}
    sudo chown root:root ${dst}
fi;
EOF
}

function upgrade_consul () {
    local ip=$1
    local lnk=$2
    local dst=$3
    ssh -T -i ${ssh_key} "${user}@${ip}" << EOF
set -euxo pipefail
if [[ -e ${dst} ]]; then
    sudo ln -sf ${dst} ${lnk}
fi;
EOF
}

function restart_consul () {
    local ip=$1
    ssh -T -i ${ssh_key} "${user}@${ip}" << EOF
set -euxo pipefail
sudo systemctl restart consul
EOF
}

function download_consul_template() {
    local ip=$1
    local src=$2
    local lnk=$3
    local dst=$4
    scp -i ${ssh_key} ${src} ${user}@${ip}:~/${src}
    ssh -T -i ${ssh_key} "${user}@${ip}" << EOF
set -euxo pipefail
if [[ -e ${lnk} ]]; then
    sudo cp --no-clobber ${src} ${dst}
    sudo chown root:root ${dst}
fi;
EOF
}

function upgrade_consul_template () {
    local ip=$1
    local lnk=$2
    local dst=$3
    ssh -T -i ${ssh_key} "${user}@${ip}" << EOF
set -euxo pipefail
if [[ -e ${dst} ]]; then
    sudo ln -sf ${dst} ${lnk}
fi;
EOF
}

function restart_consul_template () {
    local ip=$1
    ssh -T -i ${ssh_key} "${user}@${ip}" << EOF
set -euxo pipefail
sudo systemctl restart consul-template
EOF
}

function download_nomad () {
    local ip=$1
    local src=$2
    local lnk=$3
    local dst=$4
    scp -i ${ssh_key} ${src} ${user}@${ip}:~/${src}
    ssh -T -i ${ssh_key} "${user}@${ip}" << EOF
set -euxo pipefail
if [[ -e ${lnk} ]]; then
    sudo cp --no-clobber ${src} ${dst}
    sudo chown root:root ${dst}
fi;
EOF
}

function upgrade_nomad () {
    local ip=$1
    local lnk=$2
    local dst=$3
    ssh -T -i ${ssh_key} "${user}@${ip}" << EOF
set -euxo pipefail
if [[ -e ${dst} ]]; then
    sudo ln -sf ${dst} ${lnk}
fi;
EOF
}

function restart_nomad () {
    local ip=$1
    ssh -T -i ${ssh_key} "${user}@${ip}" << EOF
set -euxo pipefail
sudo systemctl restart nomad
EOF
}

function download_vault () {
    local ip=$1
    local src=$2
    local lnk=$3
    local dst=$4
    scp -i ${ssh_key} ${src} ${user}@${ip}:~/${src}
    ssh -T -i ${ssh_key} "${user}@${ip}" << EOF
set -euxo pipefail
if [[ -e ${lnk} ]]; then
    sudo cp --no-clobber ${src} ${dst}
    sudo chown root:root ${dst}
fi;
EOF
}

function upgrade_vault () {
    local ip=$1
    local lnk=$2
    local dst=$3
    ssh -T -i ${ssh_key} "${user}@${ip}" << EOF
set -euxo pipefail
if [[ -e ${dst} ]]; then
    sudo ln -sf ${dst} ${lnk}
fi;
EOF
}

function restart_vault () {
    local ip=$1
    ssh -T -i ${ssh_key} "${user}@${ip}" << EOF
set -euxo pipefail
sudo systemctl restart vault
EOF
}

function download_levant () {
    local ip=$1
    local src=$2
    local lnk=$3
    local dst=$4
    scp -i ${ssh_key} ${src} ${user}@${ip}:~/${src}
    ssh -T -i ${ssh_key} "${user}@${ip}" << EOF
set -euxo pipefail
if [[ -e ${lnk} ]]; then
    sudo cp --no-clobber ${src} ${dst}
    sudo chown root:root ${dst}
fi;
EOF
}

function upgrade_levant () {
    local ip=$1
    local lnk=$2
    local dst=$3
    ssh -T -i ${ssh_key} "${user}@${ip}" << EOF
set -euxo pipefail
if [[ -e ${dst} ]]; then
    sudo ln -sf ${dst} ${lnk}
fi;
EOF
}

function autofs () {
    local ip=$1
    local nfs=$2
    ssh -T -i ${ssh_key} "${user}@${ip}" << EOF
set -euxo pipefail
sudo apt-get install -y autofs
EOF
}

function invalid_parameter {
    echo "Invalid parameter $1" >&2
    usage
    exit 1
}

function warn () {
    echo "$1" >&2;
}

function tag_resources() {
    local tag_name=$1
    shift
    local tag_value=$1
    shift
    local subscription_name=$1
    shift
    local resource_group_name=$1
    az login --use-device-code
    az account set -n $subscription_name
    r=$(az resource list -g $resource_group_name --query [].id --output tsv)
    for resource_id in $r; do
        result=$(az resource show --ids $resource_id --query tags)
        tags=$(echo $result | tr -d '"{},' | sed 's/: /=/g')
        tags=$tags" "$tag_name"="$tag_value
        az resource tag --tags $tags --ids $resource_id || warn "Label not updated."
    done;
}

function postgres_dump() {
    local ip=$1
    local dotted_date=$(date '+%Y.%m.%d')
    ssh -T -i ${ssh_key} "${user}@${ip}" << EOF
set -euxo pipefail
set +x
sudo pg_dump -Fc -f '/nfsdisk/postgres-backup/${dotted_date}.${postgres_database}.dump' 'user=${postgres_username} password=${postgres_password} host=${postgres_host} port=${postgres_port} dbname=${postgres_database}'
set -x
EOF
}

function postgres_restore() {
    local ip=$1
    local dotted_date=$2  # 2024.09.18
    ssh -T -i ${ssh_key} "${user}@${ip}" << EOF
set -euxo pipefail
set +x
sudo pg_restore -d 'user=${postgres_username} password=${postgres_password} host=${postgres_host} port=${postgres_port} dbname=${postgres_database}' '/nfsdisk/postgres-backup/${dotted_date}.${postgres_database}.dump'
set -x
EOF
}
