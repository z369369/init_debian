#!/bin/bash

folder_path=/media/lwh/backup_disk/google_photo

# using [ expression ] syntax and in place 
# of File.txt you can write your file name 
if [ -d $folder_path ]; 
then

# if file exist the it will be printed 
echo "File is exist"
cd $folder_path
pwd
find . -name \*.json -type f -delete

else

# is it is not exist then it will be printed
echo "File is not exist"
fi
