#!/bin/bash
echo "============== [S] Install - flatpak =============="

sudo rm -rf /var/lib/flatpak
sudo mkdir -p ~/.var/lib/flatpak
sudo ln -s ~/.var/lib/flatpak /var/lib/flatpak

sudo apt-get install -y flatpak
sudo apt-get install -y gnome-software-plugin-flatpak
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

sudo flatpak install -y $(cat pkglist_flatpak)
sudo chown -R lwh:lwh ~/.var

echo "============== [E] Install - flatpak =============="
