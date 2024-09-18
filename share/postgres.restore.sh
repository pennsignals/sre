#! /usr/bin/env bash

ip="${C}.${jump_ips[0]}"

source vars.sh

local dotted_date=$1

postgres_restore $ip $dotted_date
