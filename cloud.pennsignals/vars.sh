#!/usr/bin/env bash
set -euxo pipefail

C="10.145.248"
user="signals"
ssh_key=".ssh/acs_key"

nfs_ips=("7")
user_ips=("4" "5" "6" "8")

all_ips=( "${nfs_ips[@]}" "${user_ips[@]}")

source lib.sh
