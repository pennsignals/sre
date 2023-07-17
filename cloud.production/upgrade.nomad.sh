#!/usr/bin/env bash
set -euxo pipefail

source vars.sh

src="nomad-${nomad_version}"
zip="${src}.zip"
dst="/usr/local/bin/${src}"
lnk="/usr/local/bin/nomad"

wget -O ${zip} "https://releases.hashicorp.com/nomad/${nomad_version}/nomad_${nomad_version}_linux_amd64.zip"
sudo unzip ${zip}
sudo mv nomad ${src}

ips=( "${all_ips[@]}" )
for N in "${!ips[@]}";
do
	ip="${C}.${ips[$N]}"
        download_nomad $ip $src $lnk $dst
done;

ips=( "${all_ips[@]}" )
for N in "${!ips[@]}";
do
	ip="${C}.${ips[$N]}"
        upgrade_nomad $ip $lnk $dst
done;

ips=( "${nomad_ips[@]}" )
for N in "${!ips[@]}";
do
	ip="${C}.${ips[$N]}"
        restart_nomad $ip
done;

ips=( "${minion_ips[@]}" )
for N in "${!ips[@]}";
do
	ip="${C}.${ips[$N]}"
        restart_nomad $ip
done;
