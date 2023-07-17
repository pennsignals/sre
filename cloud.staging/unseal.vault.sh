#!/usr/bin/env bash
set -euxo pipefail

source vars.sh

# delay with nomad nodes so that both consul and vault nodes are back up
ips=( "${vault_ips[@]}" )
for N in "${!ips[@]}";
do
	ip="${C}.${ips[$N]}"
        vault_unseal $ip
done;
