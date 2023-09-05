#!/bin/bash

# Get the path to the camera folder
target_folder="/home/lwh/Pictures/"

# Find all the image files in the camera folder
image_files=$(find "$target_folder" -type f -iname "*.jpg" -o -iname "*.png") 

# Print the names of the image files
for image_file in $image_files; do

  v_w=$(identify -format '%w' $image_file)
  v_h=$(identify -format '%h' $image_file)
  if [ $v_w -gt 3000 ] && [ $v_h -gt 3000 ] 
  then
  	echo "Modify $image_file $v_w $v_h"
  	convert -resize 50% "$image_file" "$image_file"
  else
   	echo "______ $image_file $v_w $v_h"
  fi
  
  #echo $image_file
  
  #image_file2=${image_file/$camera_folder/$camera_folder2} 
  #echo "$image_file2"
  #exif --remove "$image_file" --output="$image_file"
  #convert -resize 50% "$image_file" "$image_file2"
  #rm -rf $image_file
done
