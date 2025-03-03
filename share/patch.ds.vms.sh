#!/usr/bin/env bash
#set -euxo pipefail

source vars.sh

#Patch all VMs in a resource group.
#Must be run with VPN on and only by users with ssh access to VMs

expected="${falcon_sensor_version}"
src="falcon-sensor.deb"
wget -O ${src} "https://paloaltocontent.uphs.upenn.edu/Agents/CS_Ubuntu_Sensor.deb"
actual="$(dpkg --info ${src} | grep Version)"
actual="${actual:10}"  #  Version: xxxxxx
if [ $actual != $expected ]; then
        printf "Unexpected cloudstrike falcon-sensor version: Actual: ${actual} != Expected: ${expected}">&2
fi;
dst="falcon-sensor-${actual}.deb"
mv ${src} ${dst}
src="${dst}"

az account set --subscription "${subscription}"
az login --use-device-code
az vm start --ids $(az vm list -g "${resource_group}" --query "[].id" -o tsv)
ips_string=$(az vm list -g "${resource_group}" --query "[].privateIps" -d -o tsv)
ips=($ips_string)
is_ready=true
counter=1

while [ $counter -le 10 ]; do
  is_ready=true
  vm_list=$(az vm list -g "${resource_group}" --query '[].{Name:name,Status:powerState}' -d -o table)
  vm_list=$(echo "$vm_list" | sed '1,2d')


  while read -r line; do
    echo $line
    vm_name=$(echo $line | awk '{print $1}')
    sentence_status=${line//[$'\t']/ }
    vm_status=$(echo $sentence_status | cut -d" " -f2-)

    # Check if the VM is allocated and running.
    if [[ $vm_status != "VM running" ]]; then
      echo "VM $vm_name is not running."
      is_ready=false
    fi
  done <<< "$vm_list"
  if [ "$is_ready" = true ]; then
    break
  fi
  out_string="Retrying attempt $counter out of 10. Sleeping for 5 seconds..."
  echo $out_string
  sleep 5
  ((counter++))
done

if [ "$is_ready" = true ]; then
  for node in "${ips[@]}";
  do
    patch ${node}
  done;
  for node in "${ips[@]}";
  do
    download_falcon_sensor $node $src
  done;
  for node in "${ips[@]}";
  do
    upgrade_falcon_sensor $node $src
  done;
else
  echo "Failed to allocate all VMs. Contact Pennsignals for assistance.";
fi

#az vm deallocate --ids $(az vm list -g "${resource_group}" --query "[].id" -o tsv)

#TODO Get list of running VMs and use that to only shut down ones that were already down before patching
