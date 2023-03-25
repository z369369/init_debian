#!/bin/bash
img_dir=$HOME/Pictures/BingWallpaper
img_file=$( ls -1 "$img_dir" |  shuf | head -1 )
#echo "$HOME/Pictures/BingWallpaper/$myfile"
cat ~/.key | sudo -S /home/$USER/script/ubuntu-gdm-set-background --image "$img_dir/$img_file" > /dev/null 2>&1