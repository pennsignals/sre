#!/usr/bin/env bash
set -euxo pipefail

source vars.sh

for node in "${nomads[@]}";
do
        update_nomad_registry_auth $node $user $pat
done;

for node in "${minions[@]}";
do
        update_nomad_registry_auth $node $user $pat
done;
