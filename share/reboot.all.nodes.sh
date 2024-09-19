#!/usr/bin/env bash
set -euxo pipefail

source vars.sh
source check.all.nodes.sh

for node in "${nodes[@]}";
do
        restart $node
done;

sleep 15

until (source unseal.vault.sh)
do
    echo .
    sleep 1
done
