#! /usr/bin/env bash

source vars.sh

dotted_date=$1

postgres_restore "${jumps[0]}" "${dotted_date}"
