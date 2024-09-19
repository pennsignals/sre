#!/usr/bin/env bash
set -euxo pipefail

source vars.sh

ip="${jumps[0]}"
ssh -i ${ssh_key} "${user}@${ip}"
