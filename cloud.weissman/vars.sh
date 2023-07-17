#!/usr/bin/env bash
set -euxo pipefail

user="signals"
ssh_key=".ssh/acs_key"
C="10.145.240"
source lib.sh

all_ips=( "19" "13" "12")
