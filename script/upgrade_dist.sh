#!/bin/bash
echo "============== [S] Upgrade - ubuntu =============="
sudo do-release-upgrade
echo "============== [E] Upgrade - ubuntu =============="

echo "============== [S] Remove - snap =============="

sudo systemctl disable snapd.service
sudo systemctl disable snapd.socket
sudo systemctl disable snapd.seeded.service

sudo dpkg --configure -a
sudo apt purge snapd gnome-software-plugin-snap

sudo rm -rf /var/cache/snapd/
rm -rf ~/snap

echo "============== [E] Remove - snap =============="