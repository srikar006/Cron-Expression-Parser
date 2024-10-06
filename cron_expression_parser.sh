#!/bin/bash

# Function to expand cron field with various field inputs (e.g., "*/5", "1-5", "0,15")
expand_field() {
    local field="$1"
    local min="$2"
    local max="$3"

    # Handles various field inputs 
    if [[ "$field" == "*" ]]; then
        seq $min $max
    elif [[ "$field" == */* ]]; then
        # Handle step values like "*/15" and capture every 15th values
        step=${field#*/}
        seq $min $step $max
    elif [[ "$field" == *-* ]]; then
        # Handle ranges like "1-5" 
        seq ${field%-*} ${field#*-}
    else
        # Handles the comma-separated values like "0,15"
        echo "$field" | tr ',' ' '
    fi
}

# Function to print the field names and its expanded values
print_table() {
    local field_name="$1"
    local values="$2"
    
    # Values will be printed in the same line, replaced the new line print to space
    values=$(echo "$values" | tr '\n' ' ')
    
    # The Output will be formatted as a table with the field name taking the first 14 columns 
    printf "%-14s %s\n" "$field_name" "$values"
}

# If the user doesn't gave the proper arguemnt, this script will print a usage message which helps the user to know the corect way to run it
if [ $# -ne 1 ]; then
    echo "Usage: $0 '<cron_string>'"
    exit 1
fi

# Read the cron fields: minute, hour, day of month, month, day of week, and command
#Because of IFS the cron_sting values will be separated and the read values will be assigned to the field names accordingly
cron_string="$1"
IFS=' ' read -r minute hour dom month dow command <<< "$cron_string"

# Expand and display each field with appropriate labels
print_table "Minute" "$(expand_field "$minute" 0 59)"
print_table "Hour" "$(expand_field "$hour" 0 23)"
print_table "Day of Month" "$(expand_field "$dom" 1 31)"
print_table "Month" "$(expand_field "$month" 1 12)"
print_table "Day of Week" "$(expand_field "$dow" 0 6)"
print_table "Command" "$command"
