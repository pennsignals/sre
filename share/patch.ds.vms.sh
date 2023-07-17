#!/usr/bin/env bash
#set -euxo pipefail

source vars.sh

#Patch all VMs in a resource group.
#Must be run with VPN on and only by users with ssh access to VMs

#For Herman Lab
#./patch.ds.vms.sh DATASCIENCE-LA translational-herman

#For Weissman Lab
#./patch.ds.vms.sh DATASCIENCE-LA translational-weissman

#For general Resource Group use
#./patch.ds.vms.sh (Subscription Name) (resource group name)

az login
az account set --subscription "$1"
az vm start --ids $(az vm list -g "$2" --query "[].id" -o tsv)
ips_string=$(az vm list -g "$2" --query "[].privateIps" -d -o tsv)
ips=($ips_string)
is_ready=true
counter=1

while [ $counter -le 10 ]; do
  is_ready=true
  vm_list=$(az vm list -g $2 --query '[].{Name:name,Status:powerState}' -d -o table)
  vm_list=$(echo "$vm_list" | sed '1,2d')


  while read -r line; do
    echo $line
    vm_name=$(echo $line | awk '{print $1}')
    sentence_status=${line//[$'\t']/ }
    vm_status=$(echo $sentence_status | cut -d" " -f2-)

    # Check if the VM is allocated and running.
    if [[ $vm_status != "VM runing" ]]; then
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
  for N in "${!ips[@]}";
  do
    patch ${ips[N]}
  done;
else
  echo "Failed to allocate all VMs. Contact Pennsignals for assistance."
fi

#az vm deallocate --ids $(az vm list -g "$2" --query "[].id" -o tsv)

#TODO Get list of running VMs and use that to only shut down ones that were already down before patching
