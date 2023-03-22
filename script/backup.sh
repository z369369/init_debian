#!/bin/bash
rsync -a --exclude-from ~/phone/DCIM --exclude .stf* ~/phone/DCIM/ ~/Pictures/
#rm -rf ~/phone/DCIM/*
find ~/phone/DCIM -type f -exec rm -f {} \;


#personal backup
p_path=/media/lwh/backup_disk/Obsidian/ 
cd $p_path
backup_filename_src=Personal_`date +%Y%m%d_%H%M%S`
mkdir $backup_filename_src
rsync -a /home/lwh/phone/Personal/ $p_path$backup_filename_src/
ls -1tr | head -n -20 | xargs -d '\n' rm -rf --
