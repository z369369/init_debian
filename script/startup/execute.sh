#!/bin/bash
/home/lwh/script/startup/organize_startup.sh
/home/lwh/script/startup/fdupes_pictures.sh
python3 /home/lwh/script/startup/check_gnome_extension.py
cat ~/.key | sudo -S ufw default deny outgoing 

gnome-terminal
nohup nautilus ~ &
nohup firefox &
disown

exit 0
