#!/usr/bin/env bash
set -euxo pipefail

source vars.sh

name="config.json"
dst="/etc/nomad.d/${name}"
src="../assets${dst}"
template="../assets/etc/nomad.d/configtemplate.json"

update_config $template $src
for nomad in "${nomads[@]}";
do
        upload_registry_auth $nomad $src $user $name $dst
done;

for minion in "${minions[@]}";
do
        upload_registry_auth $minion $src $user $name $dst
done;
rm $src
