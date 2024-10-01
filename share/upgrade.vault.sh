#!/usr/bin/env bash
set -euxo pipefail

source vars.sh

src="vault-${vault_version}"
zip="${src}.zip"
dst="/usr/local/bin/${src}"
lnk="/usr/local/bin/vault"

wget -O ${zip} "https://releases.hashicorp.com/vault/${vault_version}/vault_${vault_version}_linux_amd64.zip"
sudo unzip -o ${zip}
sudo mv vault ${src}

for node in "${nodes[@]}";
do
        download_vault $node $src $lnk $dst
done;

for node in "${nodes[@]}";
do
        upgrade_vault $node $lnk $dst
done;

for vault in "${vaults[@]}";
do
        restart_vault $vault
done;
