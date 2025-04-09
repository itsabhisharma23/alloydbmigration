#!/bin/bash

CONFIG_FILE="migration.config" 


GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
RED=$(tput setaf 1)
BOLD=$(tput bold)
NC=$(tput sgr0)


# --- SSH Connection (Optional) ---

echo "${GREEN}${BOLD}Installing required packages... Getting ready...${NC}"

sudo apt-get update
sudo apt-get install -yq git python3 python3-pip python3-distutils
sudo pip install --upgrade pip virtualenv

# Installation
echo "Installing PostgreSQL client version 14.10..."

# Add PostgreSQL repository if not already added
echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" | sudo tee /etc/apt/sources.list.d/pgdg.list
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo apt-get update

# Install specific version
sudo apt-get install -y postgresql-client-14
echo ""
echo "---------------------------------------------------------"
echo "${BOLD}Installing Data Validation tool...${NC}"

virtualenv -p python3 env
source env/bin/activate
#Check if DVT is already installed
if pip3 show google-pso-data-validator >/dev/null 2>&1; then
    echo "DVT (google-pso-data-validator) is installed."

    # Optionally, show version information
    pip3 show google-pso-data-validator | grep "Version"
else
    echo "DVT (google-pso-data-validator) is not installed."
    #Install DVT
    echo "installing DVT..."
    # Install DVT
    pip install google-pso-data-validator
fi

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