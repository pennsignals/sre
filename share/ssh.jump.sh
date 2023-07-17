#!/usr/bin/env bash
set -euxo pipefail

source vars.sh

ip="${C}.${jump_ips[0]}"
ssh -i ${ssh_key} "${user}@${ip}"
