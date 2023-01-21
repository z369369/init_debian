#!/bin/bash
echo "============== [S] Remove - unuse =============="

sudo systemctl disable snapd.service
sudo systemctl disable snapd.socket
sudo systemctl disable snapd.seeded.service

sudo dpkg --configure -a
sudo apt autoremove --purge -y snapd

sudo rm -rf /var/cache/snapd/
rm -rf ~/snap

sudo apt remove --purge -y $(cat pkglist_apt_purge)

echo "============== [E] Remove - unuse =============="