#!/bin/bash
echo "============== [S] 1.Remove - Snap =============="

sudo systemctl disable snapd.service
sudo systemctl disable snapd.socket
sudo systemctl disable snapd.seeded.service

sudo dpkg --configure -a
sudo apt autoremove --purge -y snapd

sudo rm -rf /var/cache/snapd/
rm -rf ~/snap

echo "============== [E] 1.Remove - Snap =============="



echo "============== [S] 1.Remove - APT package =============="

sudo apt remove --purge -y $(cat pkg_remove_apt)

echo "============== [E] 1.Remove - APT package =============="



echo "============== [S] 1.Remove - Ubuntu default extension =============="

sudo rm -rf /usr/share/gnome-shell/extensions/*

echo "============== [S] 1.Remove - Ubuntu default extension =============="