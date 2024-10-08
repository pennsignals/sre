#!/usr/bin/env bash
set -euxo pipefail

source vars.sh

src="levant-${levant_version}"
zip="${src}.zip"
dst="/usr/local/bin/${src}"
lnk="/usr/local/bin/levant"

wget -O ${zip} "https://releases.hashicorp.com/levant/${levant_version}/levant_${levant_version}_linux_amd64.zip"
sudo unzip -o ${zip}
sudo mv levant ${src}

for node in "${jumps[@]}";
do
        download_levant $node $src $lnk $dst
done;

for node in "${jumps[@]}";
do
        upgrade_levant $node $lnk $dst
done;
