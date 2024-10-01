#!/usr/bin/env bash
set -euxo pipefail

source vars.sh

src="nomad-${nomad_version}"
zip="${src}.zip"
dst="/usr/local/bin/${src}"
lnk="/usr/local/bin/nomad"

wget -O ${zip} "https://releases.hashicorp.com/nomad/${nomad_version}/nomad_${nomad_version}_linux_amd64.zip"
sudo unzip -o ${zip}
sudo mv nomad ${src}

noservers=($(comm -23 <(printf "%s\n" "${nodes[@]}" | sort) <(print "%s\n" "${nomads[@]}" | sort)))

for node in "${nodes[@]}";
do
        download_nomad $node $src $lnk $dst
done;

for node in "${nomads[@]}";
do
        upgrade_nomad $node $lnk $dst
done;

for nomad in "${nomads[@]}";
do
        restart_nomad $nomad
        echo "Allow time for server to rejoin"
        sleep 10
done;

for node in "${noservers[@]}";
do
        upgrade_nomad $node $lnk $dst
done;

for node in "${minions[@]}";
do
        restart_nomad $node
done;
