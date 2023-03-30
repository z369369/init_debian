#!/bin/bash
echo "============== [S] 1.Remove - snap =============="
sudo systemctl disable snapd.service
sudo systemctl disable snapd.socket
sudo systemctl disable snapd.seeded.service

sudo dpkg --configure -a
sudo apt autoremove --purge -y snapd

sudo rm -rf /var/cache/snapd/
rm -rf ~/snap
echo "============== [E] 1.Remove - snap =============="

echo "============== [S] 1.Remove - remove package =============="
sudo apt remove --purge -y $(cat pkg_apt_remove)
echo "============== [E] 1.Remove - remove package =============="

echo "============== [S] 1.Remove - ubuntu default extension =============="
sudo rm -rf /usr/share/gnome-shell/extensions/*
echo "============== [S] 1.Remove - ubuntu default extension =============="