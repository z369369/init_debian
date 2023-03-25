#!/bin/bash


cd /home/lwh/Desktop

for i in /home/lwh/Desktop/*.desktop; do    gio set "$i" "metadata::trusted" true ; chmod +x "$i";done

touch /home/lwh/Desktop

#notify-send 'Complete' 'Press F5 for refresh Desktop'
