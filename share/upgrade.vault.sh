#!/usr/bin/env bash
set -euxo pipefail

source vars.sh

src="vault-${vault_version}"
zip="${src}.zip"
dst="/usr/local/bin/${src}"
lnk="/usr/local/bin/vault"

wget -O ${zip} "https://releases.hashicorp.com/vault/${vault_version}/vault_${vault_version}_linux_amd64.zip"
sudo unzip ${zip}
sudo mv vault ${src}

ips=( "${all_ips[@]}" )
for N in "${!ips[@]}";
do
	ip="${C}.${ips[$N]}"
        download_vault $ip $src $lnk $dst
done;

ips=( "${all_ips[@]}" )
for N in "${!ips[@]}";
do
	ip="${C}.${ips[$N]}"
        upgrade_vault $ip $lnk $dst
done;

ips=( "${vault_ips[@]}" )
for N in "${!ips[@]}";
do
	ip="${C}.${ips[$N]}"
        restart_vault $ip
done;
