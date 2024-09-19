#!/usr/bin/env bash
set -euxo pipefail

source vars.sh

for node in "${nodes[@]}";
do
        patch $node
done;

source reboot.all.nodes.sh
