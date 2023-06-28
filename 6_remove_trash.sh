#!/bin/bash
echo "============== [S] [6 / 6] Remove trash =============="

sudo apt remove --purge -y $(grep -vE "^\s*#" remove.list | sed -e 's/#.*//'  | tr "\n" " ")

sudo rm -rf /usr/share/gnome/applications/nemo.desktop
sudo rm -rf /usr/share/gnome-shell/extensions/*

sudo systemctl disable NetworkManager-wait-online.service
sudo systemctl disable bluetooth.service

sudo systemctl enable syncthing@lwh.service

echo "============== [E] [6 / 6] Remove trash =============="
