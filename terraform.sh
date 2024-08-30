#!/bin/bash


#Clone Terraform module repository for alloydb
git clone https://github.com/GoogleCloudPlatform/terraform-google-alloy-db.git

#Clone Terraform module repository for cloudSQL
#git clone https://github.com/terraform-google-modules/terraform-google-sql-db.git


cd terraform-google-alloy-db

# Path to the variables.tf file
file="variables.tf"

# Check if the file exists
if [ ! -f "$file" ]; then
  echo "ERROR: File $file not found."
  exit 1
fi

#if private service connect should be enabled, do the following, else comment it out
#Replace 'default     = false' with 'default     = true' for psc_enabled - the psc_enabled should be set to true
sed -i '' 's/default     = false/default     = true/g' "$file"

echo "Default value for psc_enabled has been changed to true in $file"

#if not using private service connect, if network id needs to be set provide network id below
#network_id="network_id"
# Set the value of network_self_link in the Terraform file 
#uncomment the below lines--
# sed -i "s/network_self_link\s*=\s*null/network_self_link = \"$network_id\"/g" "$file"

# echo "Network self link has been set to $network_id" 




#Initialize Terraform
terraform init 

#Create a Terraform execution plan
terraform plan

# Apply the Terraform configuration to create the AlloyDB cluster
terraform apply -var 'primary_instance={instance_id="my-primary-instance"}'
