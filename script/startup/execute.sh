#!/bin/bash
#sound
~/script/startup/fdupes_pictures.sh
#~/script/startup/wallpaper.sh
#python3 ~/script/py/startup_gnome_extension.py
cat ~/.key | sudo -S ufw default deny outgoing 
cat ~/.key | sudo -S systemctl start bluetooth.service
cat ~/.key | sudo -S ufw enable

wmctrl -s 4
gnome-terminal

wmctrl -s 3
nohup nautilus ~ 1> /dev/null 2>&1 &
nohup firefox-esr 1> /dev/null 2>&1 &
#nohup syncthing --allow-newer-config --no-browser 1> /dev/null 2>&1 &
disown

exit 0
