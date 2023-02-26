#!/bin/bash
echo "============== [S] Install - apt =============="

sudo apt-get install -y $(cat pkglist_apt)
sudo apt-get update && sudo apt-get -y upgrade

echo "============== [E] Install - apt =============="

echo "============== [S] Install - flatpak =============="

sudo rm -rf /var/lib/flatpak
sudo mkdir -p ~/.var/lib/flatpak
sudo ln -s ~/.var/lib/flatpak /var/lib/flatpak

sudo apt-get install -y flatpak
sudo apt-get install -y gnome-software-plugin-flatpak
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

sudo flatpak install -y $(cat pkglist_flatpak)
sudo chown -R lwh:lwh ~/.var

#obs not work
#https://unix.stackexchange.com/questions/552688/is-it-possible-to-roll-back-a-flatpak-update
#flatpak remote-info --log flathub org.gimp.GIMP
sudo flatpak update --commit=694f40fda5aea03f5daf53db094cdcc5c29e62fa507d49d5bcfe399c55809ecd com.obsproject.Studio
echo "============== [E] Install - flatpak =============="