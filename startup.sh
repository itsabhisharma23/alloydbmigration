#!/bin/bash

CONFIG_FILE="migration.config" 

GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
RED=$(tput setaf 1)
BOLD=$(tput bold)
NC=$(tput sgr0)

# Source the banner script (assuming it exists in the same directory)
if [ -f "./banner.sh" ]; then
  source ./banner.sh
else
  echo "Warning: banner not found."
fi

echo -e "\n\nSelect the source PostgreSQL type:\n"
echo "1. On-premise"
echo "2. AWS"
echo "3. Azure"

read -p "Enter your choice (1-3): " source_type

# Validate source_type input
case "$source_type" in
  1)
    source_type_name="On-premise"
    ;;
  2)
    source_type_name="AWS"
    ;;
  3)
    source_type_name="Azure"
    ;;
  *)
    echo -e "\nError: Invalid source type selected. Please enter a number between 1 and 3."
    exit 1 # Exit with an error code
    ;;
esac

echo -e "\n\nSelect the target type:\n"
echo "1. AlloyDB"
echo "2. CloudSQL"

read -p "Enter your choice (1-2): " target_type

# Validate target_type input
case "$target_type" in
  1)
    target_type_name="AlloyDB"
    ;;
  2)
    target_type_name="CloudSQL"
    ;;
  *)
    echo -e "\nError: Invalid target type selected. Please enter either 1 or 2."
    exit 1 # Exit with an error code
    ;;
esac

if [[ -f "$CONFIG_FILE" ]]; then
  echo "\nLoading your configuration from $CONFIG_FILE"
  source "$CONFIG_FILE"
else
  echo "\nWarning: Configuration file '$CONFIG_FILE' not found. "
fi

echo ""
echo "-------------------------------------------------------------------------------------"
echo "You are about to migrate databases from ${GREEN}$source_type_name${NC} to ${GREEN}$target_type_name${NC}."
echo "-------------------------------------------------------------------------------------"
echo ""

# Create the connection profile for source(PostgreSQL DB)
# Provide --cloudsql-instance if source DB is CloudSQL(Postgre) 

echo "${YELLOW}Creating source profile...${NC}"

# connection profile for source DB
gcloud database-migration connection-profiles create postgresql "$SOURCE_PROFILE_NAME" \
    --region="$REGION" \
    --display-name="$SOURCE_PROFILE_NAME" \
    --username="$SOURCE_USER" \
    --host="$SOURCE_HOST" \
    --port="$SOURCE_PORT" \
    --prompt-for-password \
    --project="$PROJECT_ID"

# Check if the profile creation was successful
if [ $? -eq 0 ]; then
  echo "${GREEN}Connection profile \"${BOLD}$SOURCE_PROFILE_NAME${NC}${GREEN}\" created successfully.${NC}"
else
  echo "${RED}Error: Failed to create connection profile \"${BOLD}$SOURCE_PROFILE_NAME${NC}${RED}\".${NC}"
  exit 1
fi

# Create the connection profile for alloyDB/CloudSQL(postgresql) destination
# Provide --cloudsql-instance if source DB is CLoudSQL(Postgre) else provide --alloydb-cluster property.

if (( target_type_name == "AlloyDB" )); then
    echo "\n${YELLOW}creating destination profile for AlloyDB.${NC}\n"
    gcloud database-migration connection-profiles create postgresql $DESTINATION_PROFILE_NAME \
    --region=$REGION \
    --display-name=$DESTINATION_PROFILE_NAME \
    --alloydb-cluster=$DESTINATION_ALLOYDB \
    --username=$DESTINATION_USER \
    --host=$DESTINATION_HOST \
    --port=$DESTINATION_PORT \
    --prompt-for-password \
    --project=$PROJECT_ID
else
    echo "\n${YELLOW}creating destination profile for CloudSQL.${NC}\n"
    gcloud database-migration connection-profiles create postgresql $DESTINATION_PROFILE_NAME \
    --region=$REGION \
    --display-name=$DESTINATION_PROFILE_NAME \
    --cloudsql-instance=$DESTINATION_CloudSQL_INSTANCE_NAME \
    --username=$DESTINATION_USER \
    --host=$DESTINATION_HOST \
    --port=$DESTINATION_PORT \
    --prompt-for-password \
    --project=$PROJECT_ID
fi

# Check if the profile creation was successful
if [ $? -eq 0 ]; then
  echo "${GREEN}Connection profile \"${BOLD}$DESTINATION_PROFILE_NAME${NC}${GREEN}\" created successfully.${NC}"
else
  echo "${RED}Error: Failed to create connection profile \"${BOLD}$DESTINATION_PROFILE_NAME${NC}${RED}\".${NC}"
  exit 1
fi
exit 0 # Exit with a success code