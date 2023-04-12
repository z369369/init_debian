#!/bin/bash

cat ~/.key | sudo -S systemctl restart bluetooth.service

img_dir=$HOME/.local/share/BingWallpaper
img_file=$( ls -1 "$img_dir" |  shuf | head -1 )
#echo "$HOME/Pictures/BingWallpaper/$myfile"
cat ~/.key | sudo -S /home/$USER/script/startup/ubuntu-gdm-set-background --image "$img_dir/$img_file" > /dev/null 2>&1
