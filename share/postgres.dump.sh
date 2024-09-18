#! /usr/bin/env bash

source vars.sh

ip="${C}.${jump_ips[0]}"

postgres_dump $ip
