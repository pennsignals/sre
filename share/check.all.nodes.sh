#!/usr/bin/env bash
set -euxo pipefail

source vars.sh

for node in "${nodes[@]}";
do
        check $node
done;
