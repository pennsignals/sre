#!/usr/bin/env bash
set -euxo pipefail
#Removes password expiration of a user on all nodes in on premise group
#./remove.passwd.expiration.sh username

source vars.sh

ips=( "${all_ips[@]}" )
for N in "${!ips[@]}";
do
	ip="${C}.${ips[$N]}"
  remove_passwd_expiration "$1"
done;
