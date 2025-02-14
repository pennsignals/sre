#!/usr/bin/env bash
set -euxo pipefail

source vars.sh

expected="${falcon_sensor_version}"
src="falcon-sensor.deb"
lnk="/usr/local/bin/falcon-sensor"

wget -O ${src} "https://paloaltocontent.uphs.upenn.edu/Agents/CS_Ubuntu_Sensor.deb"
actual="$(dpkg --info ${src} | grep Version)"
actual="${actual:9}"  #  Version: xxxxxx
if [ $actual != $expected ]; then
        printf "Unexpected cloudstrike falcon-sensor version: Actual: ${actual} != Expected: ${expected}">&2
fi;
dst="falcon-sensor-${actual}.deb"
mv ${src} ${dst}
src="${dst}"

for node in "${jumps[@]}";
do
        download_falcon_sensor $node $src $lnk
done;

for node in "${jumps[@]}";
do
        upgrade_falcon_sensor $node $src $lnk
done;
