#!/bin/bash

CONFIG_FILE="migration.config" 

TERM="xterm"
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
RED=$(tput setaf 1)
BOLD=$(tput bold)
NC=$(tput sgr0)

if [[ -f "$CONFIG_FILE" ]]; then
  echo "\nLoading your configuration from $CONFIG_FILE"
  source "$CONFIG_FILE"
else
  echo "\nWarning: Configuration file '$CONFIG_FILE' not found. "
fi

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

echo ""
echo "---------------------------------------------------------"
echo "${BOLD}Running Validations ... ${NC}"
echo "Adding postgresql source connection...."
data-validation connections add --connection-name=$CONN_NAME Postgres --host=$SOURCE_HOST --port=$SOURCE_PORT --user=$SOURCE_USER --password=$DVT_SOURCE_PASSWORD --database=$DB_NAME   

echo "adding postgresql distination connection...."
data-validation connections add --connection-name=$DEST_CONN_NAME Postgres \
    --host=$DESTINATION_HOST \
    --port=$DESTINATION_PORT \
    --user=$DESTINATION_USER \
    --password=$DVT_DEST_PASSWORD \
    --database=$DB_NAME 

########################################################
#####DVT Validations####################################
# Iterate through schemas
for schema in "${SCHEMAS[@]}"; do

  ############################
  # Object Count Validations
  ############################

  # Table Count Validation
    data-validation validate column \
    -sc $CONN_NAME \
    -tc $DEST_CONN_NAME \
    --tables-list information_schema.tables \
    --filters "table_schema = '$schema'" \
    -bqrh $PROJECT_ID.$BQ_DVT_DATASET.results

  # View Count Validation
    data-validation validate column \
    -sc $CONN_NAME \
    -tc $DEST_CONN_NAME \
    --tables-list information_schema.views \
    --filters "table_schema = '$schema'" \
    -bqrh $PROJECT_ID.$BQ_DVT_DATASET.results

  # Routines Count Validation
    data-validation validate column \
    -sc $CONN_NAME \
    -tc $DEST_CONN_NAME \
    --tables-list information_schema.routines \
    --filters "routine_schema = '$schema'" \
    -bqrh $PROJECT_ID.$BQ_DVT_DATASET.results

  # Primary Key Count Validation
    data-validation validate column \
    -sc $CONN_NAME \
    -tc $DEST_CONN_NAME \
    --tables-list information_schema.table_constraints \
    --filters "constraint_type = 'PRIMARY KEY' AND table_schema = '$schema'" \
    -bqrh $PROJECT_ID.$BQ_DVT_DATASET.results

  # Foreign Key Count Validation
    data-validation validate column \
    -sc $CONN_NAME \
    -tc $DEST_CONN_NAME \
    --tables-list information_schema.table_constraints \
    --filters "constraint_type = 'FOREIGN KEY' AND table_schema = '$schema'" \
    -bqrh $PROJECT_ID.$BQ_DVT_DATASET.results

  # Constraints Count Validation
    data-validation validate column \
    -sc $CONN_NAME \
    -tc $DEST_CONN_NAME \
    --tables-list information_schema.table_constraints \
    --filters "table_schema = '$schema'" \
    -bqrh $PROJECT_ID.$BQ_DVT_DATASET.results

  # Functions Count Validation
    data-validation validate column \
    -sc $CONN_NAME \
    -tc $DEST_CONN_NAME \
    --tables-list information_schema.routines \
    --filters "routine_type = 'FUNCTION' AND routine_schema = '$schema'" \
    -bqrh $PROJECT_ID.$BQ_DVT_DATASET.results
 
  # Sequence Count Validation
    data-validation validate column \
    -sc $CONN_NAME \
    -tc $DEST_CONN_NAME \
    --tables-list information_schema.sequences \
    --filters "sequence_schema = '$schema'" \
    -bqrh $PROJECT_ID.$BQ_DVT_DATASET.results



  export PGPASSWORD=$DVT_SOURCE_PASSWORD
  # Get tables in the schema
  tables=$(psql -U $SOURCE_USER -h $SOURCE_HOST -p $SOURCE_PORT -d $DB_NAME -At -c "SELECT table_name FROM information_schema.tables WHERE table_schema = '$schema'")
  # Iterate through tables
  for table in $tables; do
    echo "  Validating table schema for: $table"

    # Schema Validations
    data-validation validate schema \
    -sc $CONN_NAME \
    -tc $DEST_CONN_NAME \
    --tables-list $schema.$table \
    -bqrh $PROJECT_ID.$BQ_DVT_DATASET.results

    # Column Validation, Row count validations, 
    # Please update all the validations to be done prior to the promotion
    #refer https://github.com/GoogleCloudPlatform/professional-services-data-validator

  done

done

vim -c "wq" "$INPUT_CSV"
echo "Validating table row count with filters..."
tail -n +2 "$INPUT_CSV" | while IFS=, read -r schema_name table_name filter_condition; do
    if [ "$schema_name" = "schema_name" ]; then 
        echo "skipping header row"
    else
        echo "Validating row count for table: $schema_name.$table_name with filter: $filter_condition"
          #Count Validations
          data-validation validate column \
          -sc $CONN_NAME \
          -tc $DEST_CONN_NAME \
          --tables-list $schema_name.$table_name \
          --filters $filter_condition \
          -bqrh $PROJECT_ID.$BQ_DVT_DATASET.results
    fi
done

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