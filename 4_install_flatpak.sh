#!/bin/bash
echo "============== [S] 4.Install - Flatpak =============="

sudo rm -rf /var/lib/flatpak
sudo mkdir -p ~/.var/lib/flatpak
sudo ln -s ~/.var/lib/flatpak /var/lib/flatpak

sudo add-apt-repository ppa:flatpak/stable
sudo apt update
sudo apt-get install -y flatpak
sudo apt-get install -y gnome-software-plugin-flatpak
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

sudo flatpak install -y $(cat pkg_install_flatpak)
sudo chown -R $USER:$USER ~/.var

echo "============== [E] 4.Install - Flatpak =============="