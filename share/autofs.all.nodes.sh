#!/usr/bin/env bash
set -euxo pipefail

source vars.sh

nojumps=($(comm -23 <(printf "%s\n" "${nodes[@]}" | sort) <(printf "%s\n" "${jumps[@]}" | sort)))

for node in "${nodes[@]}";
do
        autofs ${node} ${jumps[0]}
done;
