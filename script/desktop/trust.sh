#!/bin/bash


cd /home/$USER/Desktop

for i in /home/$USER/Desktop/*.desktop; do    gio set "$i" "metadata::trusted" true ; chmod +x "$i";done

touch /home/$USER/Desktop

#notify-send 'Complete' 'Press F5 for refresh Desktop'
