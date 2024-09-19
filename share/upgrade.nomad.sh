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

for node in "${nodes[@]}";
do
        download_nomad $node $src $lnk $dst
done;

for node in "${nodes[@]}";
do
        upgrade_nomad $node $lnk $dst
done;

for nomad in "${nomads[@]}";
do
        restart_nomad $nomad
done;

for minion in "${minions[@]}";
do
        restart_nomad $minion
done;
