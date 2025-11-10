#!/bin/bash
echo "============== [S] [6 / 6] Remove trash =============="

sudo apt remove --purge -y $(grep -vE "^\s*#" remove_package.list | sed -e 's/#.*//'  | tr "\n" " ")

sudo rm -rf /usr/share/gnome/applications/nemo.desktop

sudo systemctl disable NetworkManager-wait-online.service
# sudo systemctl disable bluetooth.service
sudo systemctl disable apt-daily.service
sudo systemctl disable apt-daily.timer
sudo systemctl disable apt-daily-upgrade.timer
sudo systemctl disable apt-daily-upgrade.service

echo "============== [E] [6 / 6] Remove trash =============="
