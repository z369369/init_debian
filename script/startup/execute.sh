#!/bin/bash
/home/lwh/script/startup/fdupes_pictures.sh
#/home/lwh/script/startup/wallpaper.sh
#python3 /home/lwh/script/py/startup_gnome_extension.py
cat ~/.key | sudo -S ufw default deny outgoing 
cat ~/.key | sudo -S systemctl start bluetooth.service
cat ~/.key | sudo -S ufw enable

gnome-terminal
nohup nautilus ~ 1> /dev/null 2>&1 &
nohup firefox-esr 1> /dev/null 2>&1 &
nohup syncthing --allow-newer-config --no-browser 1> /dev/null 2>&1 &
wmctrl -s 2
disown

exit 0
