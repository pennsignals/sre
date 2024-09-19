#!/usr/bin/env bash
set -euxo pipefail

source vars.sh

# delay with nomad nodes so that both consul and vault nodes are back up
for vault in "${vaults[@]}";
do
        vault_unseal $vault
done;
