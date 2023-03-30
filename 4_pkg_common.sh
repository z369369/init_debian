#!/bin/bash
echo "============== [S] 4.Install - apt =============="

sudo apt-get install -y $(cat pkg_apt_install)
sudo apt-get update && sudo apt-get -y upgrade

echo "============== [E] 4.Install - apt =============="



echo "============== [S] 4.Install - flatpak =============="

sudo rm -rf /var/lib/flatpak
sudo mkdir -p ~/.var/lib/flatpak
sudo ln -s ~/.var/lib/flatpak /var/lib/flatpak

sudo add-apt-repository ppa:flatpak/stable
sudo apt update
sudo apt-get install -y flatpak
sudo apt-get install -y gnome-software-plugin-flatpak
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

sudo flatpak install -y $(cat pkg_flatpak_install)
sudo chown -R $USER:$USER ~/.var

echo "============== [E] 4.Install - flatpak =============="