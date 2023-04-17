#!/bin/bash
sleep 5s
gnome-terminal
nautilus ~
#/usr/bin/google-chrome
firefox &
cat ~/.key | sudo -S ufw default deny outgoing > /dev/null
