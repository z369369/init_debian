#!/bin/bash

# Get the path to the camera folder
camera_folder="/home/lwh/Pictures/Camera/"
camera_folder2="/home/lwh/Pictures/Camera/Camera_Resized/"

# Find all the image files in the camera folder
image_files=$(find "$camera_folder" -maxdepth 1 -type f -iname "*.jpg" -o -iname "*.png")

# Print the names of the image files
for image_file in $image_files; do
  #echo $image_file
  image_file2=${image_file/$camera_folder/$camera_folder2} 
  #echo "$image_file2"
  #exif --remove "$image_file" --output="$image_file"
  convert -resize 50% "$image_file" "$image_file2"
  rm -rf "$image_file"
done

