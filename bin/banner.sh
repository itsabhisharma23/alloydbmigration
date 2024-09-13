#!/bin/bash

# Print banner
sudo apt-get install -y figlet
figlet PostgreSQL Migration to GCP
echo 
echo "$(tput setaf 2)Automated GCP migration tool for PostgreSQL to AlloyDB / CloudSQL$(tput setaf 7)"
echo "Tool created by: Abhi Sharma & Dipinti Manandhar"
echo "*********************************************************"
echo -e "This tool can automate end-to-end PostgreSQL migration to CloudSQL or AlloyDB using Database Migration Service.\n"