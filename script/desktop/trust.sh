#!/bin/bash

v_path='/home/lwh/.local/share/applications'
cd $v_path
for i in $v_path/*.desktop; do    gio set "$i" "metadata::trusted" true ; chmod +x "$i";done


v_path='/home/lwh/Desktop'
cd $v_path
for i in $v_path/*.desktop; do    gio set "$i" "metadata::trusted" true ; chmod +x "$i";done


touch /home/lwh/Desktop

#notify-send 'Complete' 'Press F5 for refresh Desktop'
