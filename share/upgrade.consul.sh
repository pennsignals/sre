#!/usr/bin/env bash
set -euxo pipefail

source vars.sh

src="consul-${consul_version}"
zip="${src}.zip"
dst="/usr/local/bin/${src}"
lnk="/usr/local/bin/consul"

wget -O ${zip} "https://releases.hashicorp.com/consul/${consul_version}/consul_${consul_version}_linux_amd64.zip"
sudo unzip ${zip}
sudo mv consul ${src}

for node in "${nodes[@]}";
do
        download_consul $node $src $lnk $dst
done;

for node in "${nodes[@]}";
do
        upgrade_consul $node $lnk $dst
done;

for node in "${consuls[@]}";
do
        restart_consul $node
done;

clients=($(comm -23 <(printf "%s\n" "${nodes[@]}" | sort) <(print "%s\n" "${consuls[@]}" | sort)))
for node in "${clients[@]}";
do
	restart_consul $node
done;
