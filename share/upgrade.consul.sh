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

ips=( "${all_ips[@]}" )
for N in "${!ips[@]}";
do
	ip="${C}.${ips[$N]}"
        download_consul $ip $src $lnk $dst
done;

ips=( "${all_ips[@]}" )
for N in "${!ips[@]}";
do
	ip="${C}.${ips[$N]}"
        upgrade_consul $ip $lnk $dst
done;

ips=( "${all_ips[@]}" )
for N in "${!ips[@]}";
do
	ip="${C}.${ips[$N]}"
	restart_consul $ip
done;
