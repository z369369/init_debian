#!/bin/bash
echo "============== [S] Install - apt =============="

sudo apt-get install -y $(cat pkglist_apt)
sudo apt-get update && sudo apt-get -y upgrade

echo "============== [E] Install - apt =============="

echo "============== [S] Install - flatpak =============="

sudo rm -rf /var/lib/flatpak
sudo mkdir -p ~/.var/lib/flatpak
sudo ln -s ~/.var/lib/flatpak /var/lib/flatpak

sudo add-apt-repository ppa:flatpak/stable
sudo apt update
sudo apt-get install -y flatpak
sudo apt-get install -y gnome-software-plugin-flatpak
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

sudo flatpak install -y $(cat pkglist_flatpak)
sudo chown -R $USER:$USER ~/.var