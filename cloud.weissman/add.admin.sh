#!/usr/bin/env bash
set -euxo pipefail
source vars.sh
#  add new admin to server:
#  add_admin.sh -p 10.0.0.150 -u 1001 -n service


function usage {
    echo ""
    echo "Script to add a root access account to server cluster."
    echo ""
    echo "usage: --user_name -n string "
    echo ""
    echo "  --admin -n string     Name of the new sudoer to create."
    echo "                          (example: service)"
    echo "  --uid -u int     User ID for new user."
    echo "                          (example: 3050)"
    echo "  --ip -p string     IP address of the server."
    echo "                          (example: 10.0.0.150)"
    echo "  --help -h                         Print usage and exit"
    echo ""
}

while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help)
            usage
            exit 0
        ;;
        -n|--admin)
            admin="$2"
        ;;
        -u|--uid)
            uid="$2"
        ;;
        -p|--ip)
            ip="$2"
        ;;
        *)
            invalid_parameter $1
    esac
    shift
    shift
done

add_admin "$ip" "$uid" "$admin"
add_keys "$ip" "$uid" "$admin"
