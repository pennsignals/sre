#!/bin/bash
set -euxo pipefail

source vars.sh

arr=()
while IFS= read -r line; do
   arr+=("$line")
done < ./backup.txt

for DB in "${arr[@]}"; do
	DATE=$(date "+%Y.%m.%d");
	printf "Archiving ${DB}.${DATE}.archive.gz";
	set +x
	mongodump --archive="${DB}.${DATE}.archive.gz" --authenticationDatabase=admin --db="${DB}" --dumpDbUsersAndRoles --forceTableScan --gzip --host="pennsignalsdb/uphsvlndc114.uphs.upenn.edu:27017" --username=superUser --password="${PASSWORD}";
	set -x
done;

wait;
