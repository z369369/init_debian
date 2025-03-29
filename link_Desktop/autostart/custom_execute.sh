#!/bin/bash
#sound
#~/Desktop/autostart/fdupes_pictures.sh
#~/Desktop/autostart/wallpaper.sh
#python3 ~/Desktop/py/autostart_gnome_extension.py
# cat ~/.key | sudo -S systemctl start bluetooth.service
cat ~/.key | sudo -S ufw default deny outgoing 
cat ~/.key | sudo -S ufw default deny incoming
cat ~/.key | sudo -S ufw enable
#cat ~/.key | sudo usbreset 2563:0526

wmctrl -s 4
gnome-terminal
sleep 1

wmctrl -s 3
nautilus &
sleep 1
#nohup nautilus ~ 1> /dev/null 2>&1 &

wmctrl -s 2
nohup firefox-esr 1> /dev/null 2>&1 &
sleep 1
#/usr/bin/flatpak run --branch=stable --arch=x86_64 --command=steam com.valvesoftware.Steam steam://open/games

#nohup syncthing --allow-newer-config --no-browser 1> /dev/null 2>&1 &
disown

#sleep 10
#sshfs -o password_stdin kmsw@kmsw.mycafe24.com:/kmsw/www /home/lwh/git/kmsw <<< 'Tmzkdl2403!@'
#sleep 10

exit 0
