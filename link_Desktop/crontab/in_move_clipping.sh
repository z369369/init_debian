#!/bin/bash
# Get the list of all folders in /home/lwh
folders=$(ls -d /home/lwh/phone/000_Personal/*/)

# Extract the folder names from the full paths
for folder in $folders; do
	folder_name=$(basename "$folder")
#	echo "$folder_name" >> /home/lwh/1.txt
  	
  	if grep -q "tags: $folder_name" "/home/lwh/phone/000_Personal/Clipping/$1"; then
#  		echo "File $1 contains the letter $folder_name." >> /home/lwh/1.txt
  		mv "/home/lwh/phone/000_Personal/Clipping/$1" "/home/lwh/phone/000_Personal/$folder_name/"
#	else
#	 	echo "File $1 does not contain the letter $folder_name." >> /home/lwh/1.txt
	fi
done

