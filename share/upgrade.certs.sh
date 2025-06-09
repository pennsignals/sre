#!/usr/bin/env bash
set -euxo pipefail

source vars.sh

curl -H "x-api-key:34LZUU6FD4Glz5qHuehHJd5Vu7dadm8f" https://cert-install.uphs.upenn.edu/api/rootcert -o "./ROOT-CA.crt"
curl -H "x-api-key:34LZUU6FD4Glz5qHuehHJd5Vu7dadm8f" https://cert-install.uphs.upenn.edu/api/subcert -o "./UPHSSUB-CA1.crt"

for node in "${nodes[@]}";
do
        download_files $node "./ROOT-CA.crt" "./UPHSSUB-CA1.crt"
done;

for node in "${nodes[@]}";
do
        upgrade_certs $node "./ROOT-CA.crt" "./UPHSSUB-CA1.crt"
done;
