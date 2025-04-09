#!/bin/bash

CONFIG_FILE="migration.config" 


GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
RED=$(tput setaf 1)
BOLD=$(tput bold)
NC=$(tput sgr0)


# --- SSH Connection (Optional) ---

echo "RUNNING PREVALIDATIONS..."
exit 1

echo "Downloading CSV file from VM..."
gcloud compute scp --project="$PROJECT_ID" --zone="$ZONE" --ssh-key-file="$KEY_FILE" "$INSTANCE_NAME":"users_and_roles.sql" "$LOCAL_SQL_FILE_1"
gcloud compute scp --project="$PROJECT_ID" --zone="$ZONE" --ssh-key-file="$KEY_FILE" "$INSTANCE_NAME":"permissions.sql" "$LOCAL_SQL_FILE_2"
gcloud compute scp --project="$PROJECT_ID" --zone="$ZONE" --ssh-key-file="$KEY_FILE" "$INSTANCE_NAME":"alter_owners.sql" "$LOCAL_SQL_FILE_3"

echo "###################################################################"
echo "A SQL file containing all the users, roles and permissions is downloaded to your machine. Please edit the file if required."
echo "Make sure you have all the usernames and passwords added in 'roles_pwd.csv' before proceeding further."
echo "Script is going to append alter commands to set passwords in 'schema_users_and_permissions.sql' file."
echo "###################################################################"
echo "Input -> roles_pwd.csv"
echo "Output -> schema_users_and_permissions.sql (adding alter statements for passwords)"
read -p "Ready to proceed? (y/n): " PROCEED
    if [[ ! "$PROCEED" =~ ^[Yy]$ ]]; then
        echo "Exiting the script..."
        exit 0
    else 
        bash prepare_roles_pwd.sh
    fi


echo "CSV file downloaded to: $LOCAL_SQL_FILE"