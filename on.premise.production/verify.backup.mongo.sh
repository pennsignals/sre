#!/bin/bash
set -euxo pipefail

source vars.sh

arr=()
while IFS= read -r line; do
   arr+=("$line")
done < ./backup.txt

for DB in "${arr[@]}"; do
	echo "Verifying ${DB}.";
	set +x
	mongorestore --dryRun --objcheck --verbose --archive="${DB}" --authenticationDatabase=admin --nsFrom="*.*" --nsTo="restore.*_*" --gzip --host="pennsignalsdb/uphsvlndc114.uphs.upenn.edu:27017" --username=superUser --password="${PASSWORD}";
	set -x
done;

wait;
