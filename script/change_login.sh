#!/bin/bash
myfile=$( ls -1 "$HOME/Pictures/BingWallpaper" |  shuf | head -1 )
#echo "$HOME/Pictures/BingWallpaper/$myfile"
echo 1 | sudo -S /home/lwh/script/ubuntu-gdm-set-background --image "$HOME/Pictures/BingWallpaper/$myfile" > /dev/null 2>&1
