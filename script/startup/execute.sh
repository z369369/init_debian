#!/bin/bash
sleep 5s
cat ~/.key | sudo -S ufw default deny outgoing > /dev/null
/home/lwh/script/startup/organize_startup.sh
/home/lwh/script/startup/fdupes_pictures.sh

gnome-terminal
nautilus ~
#/usr/bin/google-chrome
firefox &

