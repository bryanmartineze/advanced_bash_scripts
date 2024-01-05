#!/bin/bash

# Specify the path to your CSV file
csv_file="path/to/your/csvfile.csv"

# Function to extract subscription ID from the full path
extract_subscription_id() {
    full_subscription_id=$1
    subscription_id=$(basename "$full_subscription_id")
    echo "$subscription_id"
}

# Function to add subscription name column to CSV
add_subscription_name_column() {
    input_file=$1
    output_file="${input_file%.csv}_with_names.csv"

    # Add header to the new CSV file
    echo "SubscriptionID,SubscriptionName" > "$output_file"

    # Read each line from the input CSV file
    while IFS=',' read -r full_subscription_id rest_of_line; do
        # Skip the header line
        if [ "$full_subscription_id" != "SubscriptionID" ]; then
            subscription_id=$(extract_subscription_id "$full_subscription_id")
            subscription_name=$(az account show --subscription "$subscription_id" --query name -o tsv)
            echo "$full_subscription_id,$subscription_name" >> "$output_file"
        fi
    done < "$input_file"

    echo "Subscription names added to $output_file"
}

# Check if the CSV file exists
if [ -f "$csv_file" ]; then
    add_subscription_name_column "$csv_file"
else
    echo "CSV file not found: $csv_file"
fi
