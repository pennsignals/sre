#! /usr/bin/env bash

source vars.sh

local dotted_date=$1

postgres_restore "${jumps[0]}" "${dotted_date}"
