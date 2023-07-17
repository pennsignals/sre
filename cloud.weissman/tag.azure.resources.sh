#!/usr/bin/env bash
set -euxo pipefail
# Tag azure resources for ilab billing:
#
#     tag.azure.resources.sh -s datascience-la -r translational-radiology -n service_request_id -v 5467999

function usage {
    echo ""
    echo "Script to tag all resources in an Azure resource group."
    echo ""
    echo "usage: --subscription_name -s string --resource_group_name -r string --tag_name -n string --tag_value -v string "
    echo ""
    echo "  --subscription_name -s string     name of the subscription this resource group is under"
    echo "                          (example: DATASCIENCE-HA)"
    echo "  --resource_group_name -r string   name of the resource group"
    echo "                          (example: Network-watcher-rg)"
    echo "  --tag_name -n string      name of tag to create"
    echo "                          (example: Key)"
    echo "  --tag_value -v string             value of tag that is created"
    echo "                          (example: Value)"
    echo "  --help -h                         Print usage and exit"
    echo ""
}

while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help)
            usage
            exit 0
        ;;
        -s|--subscription_name)
            subscription_name="$2"
        ;;
        -r|--resource_group_name)
            resource_group_name="$2"
        ;;
        -n|--tag_name)
            tag_name="$2"
        ;;
        -v|--tag_value)
            tag_value="$2"
        ;;
        *)
            invalid_parameter $1
    esac
    shift
    shift
done

tag_resources "$tag_name" "$tag_value" "$subscription_name" "$resource_group_name"
