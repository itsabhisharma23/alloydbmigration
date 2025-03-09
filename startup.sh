#!/bin/bash

# Startup script to create PostgresSQL to CloudSQL/AlloyDB Migration
# This script is intended to do an end-to-end migration using Cloud DMS
# show banner.
source ./bin/banner.sh 
echo -e "\n\nSelect the source PostgreSQL type:\n
1. On-premise
2. AWS
3. Azure"
# Read user input and store it in the 'source_type' variable
read source_type

echo -e "\n\nSelect the target type:\n
1. AlloyDB
2. CloudSQL    ajhsg"
# Read user input and store it in the 'target_type' variable
read target_type
