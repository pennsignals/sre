#!/usr/bin/env bash
set -euxo pipefail

source vars.sh

src="consul-template-${consul_template_version}"
zip="${src}.zip"
dst="/usr/local/bin/${src}"
lnk="/usr/local/bin/consul-template"

wget -O ${zip} "https://releases.hashicorp.com/consul-template/${consul_template_version}/consul-template_${cpmsul_template_version}_linux_amd64.zip"
sudo unzip -o ${zip}
sudo mv levant ${src}

for node in "${haproxies[@]}";
do
        download_consul_template $node $src $lnk $dst
done;

for node in "${haproxies[@]}";
do
        upgrade_consul_template $node $lnk $dst
done;
