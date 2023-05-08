#!/bin/bash
/home/lwh/script/startup/organize_startup.sh
/home/lwh/script/startup/fdupes_pictures.sh
python3 /home/lwh/script/py/check_gnome_extension.py
cat ~/.key | sudo -S ufw default deny outgoing 


gnome-terminal
nohup nautilus ~ 1> /dev/null 2>&1 &
nohup firefox 1> /dev/null 2>&1 &
disown

exit 0
