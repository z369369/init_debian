#!/bin/bash
# Get the current directory

# Get a list of all files and directories in the current directory
files=$(find /home/lwh/phone/DCIM/* -type d -not -name ".*" -not -name "..")

# Get the substring to remove
substring="/home/lwh/phone/DCIM/"

# Loop through the list of files and directories
for file in $files; do

    echo "$file"

	# Remove the substring from the string
	new_string=${file//$substring}

	# Print the new string
	echo "$new_string"


done
