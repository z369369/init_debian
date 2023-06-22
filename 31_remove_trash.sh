#!/bin/bash
echo "============== [S] 31.Remove - APT package =============="

sudo apt remove --purge -y $(grep -vE "^\s*#" remove.list | sed -e 's/#.*//'  | tr "\n" " ")

echo "============== [E] 31.Remove - APT package =============="

sudo systemctl disable NetworkManager-wait-online.service

sudo apt -y remove gnome-shell-extensions

sudo rm -rf /usr/share/gnome/applications/nemo.desktop
sudo rm -rf /usr/share/gnome-shell/extensions/*