#!/usr/bin/env bash
set -euxo pipefail

user="signals"
ssh_key=".ssh/acs_key"

falcon_sensor_version="7.19.0-17221"
falcon_sensor_cid="EB648EE3E2ED4C688A4615C987F4EAEB-BF"
subscription="DATASCIENCE_DEVELOPMENT"
resource_group="radonc"

source lib.sh
