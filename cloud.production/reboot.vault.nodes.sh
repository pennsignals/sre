#!/usr/bin/env bash
set -euxo pipefail

source vars.sh

ips=( "${vault_ips[@]}" )
for N in "${!ips[@]}";
do
	ip="${C}.${ips[$N]}"
        restart $ip
done;

sleep 15

until (source unseal.vault.sh)
do
    echo .
    sleep 1
done
