#!/bin/bash

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

echo -e "\nSelected Source: $source_type_name"
echo "Selected Target: $target_type_name"


exit 0 # Exit with a success code