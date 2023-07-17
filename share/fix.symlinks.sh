#!/usr/bin/env bash
set -euxo pipefail

source vars.sh

ips=( "${all_ips[@]}" )
for N in "${!ips[@]}";
do
	ip="${C}.${ips[$N]}"
        symlink_version_fix $ip
done;
