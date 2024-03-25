#!/usr/bin/env bash
set -euxo pipefail

source vars.sh

ips=( "${jump_ips[@]}" )
for N in "${!ips[@]}";
do
	ip="${C}.${ips[$N]}"
        cleanup_nomad_periodic $ip
done;
