#!/usr/bin/env bash
set -euxo pipefail

source vars.sh

expected="${falcon_sensor_version}"
src="falcon-sensor-${expected}"
dst="/usr/local/bin/${src}"
lnk="/usr/local/bin/vault"

wget ${src} "https://paloaltocontent.uphs.upenn.edu/Agents/CS_Ubuntu_Sensor.deb"
actual=$(dpkg -s ${src} | grep Version)
actual=${expected:9}  #  Version: xxxxxx
if [ $actual != $expected ]; then
        printf "Actual: ${actual} != Expected: ${expected}">&2
        exit 1;
fi;

for node in "${jumps[@]}";
do
        download_falcon_sensor $node $src $lnk $dst
done;

for node in "${jumps[@]}";
do
        upgrade_falcon_sensor $node $lnk $dst
done;
