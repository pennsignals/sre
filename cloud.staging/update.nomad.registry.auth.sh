#!/usr/bin/env bash
set -euxo pipefail

source vars.sh

name="config.json"
dst="/etc/nomad.d/${name}"
src="../assets${dst}"
template="../assets/etc/nomad.d/configtemplate.json"

update_config $template $src
ips=( "${nomad_ips[@]}" )
for N in "${!ips[@]}";
do
	ip="${C}.${ips[$N]}"
        upload_registry_auth $ip $src $user $name $dst
done;

ips=( "${minion_ips[@]}" )
for N in "${!ips[@]}";
do
	ip="${C}.${ips[$N]}"
        upload_registry_auth $ip $src $user $name $dst
done;
rm $src
