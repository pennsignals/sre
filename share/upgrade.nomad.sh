#!/usr/bin/env bash
set -euxo pipefail

source vars.sh

servers="${1:-true}"
echo "nomad upgrade servers: ${servers}"

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

if servers; then
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
fi

for node in "${minions[@]}";
do
        upgrade_nomad $node $lnk $dst
done;


for minion in "${minions[@]}";
do
        restart_nomad $minion
done;
