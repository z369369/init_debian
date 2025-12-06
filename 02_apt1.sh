#!/bin/bash
echo "============== [S] [ 2-1 / 6 ] Install - apt =============="

sudo apt update
sudo apt -y autoremove
sudo apt autoclean
sudo apt -y upgrade

sudo apt -y --fix-broken install

sudo apt-get install -y $(grep -vE "^\s*#" install_normal.list | sed -e 's/#.*//'  | tr "\n" " " | cut -d '*' -f 1)

sudo apt -y autoremove

echo "============== [E] [ 2-1 / 6 ] Install - apt =============="

echo "============== [S] [ 2-2 / 6 ] Install - apt =============="

sudo apt update
sudo apt install -y flatpak
# sudo apt install -y gnome-software gnome-software-plugin-flatpak

echo "============== [E] [ 2-2 / 6 ] Install - apt =============="