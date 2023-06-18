#!/bin/bash
echo "============== [S] 4.Install - Flatpak =============="

#sudo rm -rf /var/lib/flatpak
#sudo mkdir -p ~/.var/lib/flatpak
#sudo ln -s ~/.var/lib/flatpak /var/lib/flatpak

#sudo add-apt-repository ppa:flatpak/stable
#by sudo 
apt update
apt install -y flatpak
apt install -y gnome-software-plugin-flatpak

#by user
flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install -y --user flathub $(grep -vE "^\s*#" install.list | sed -e 's/#.*//'  | tr "\n" " " | cut -d '*' -f 2)

flatpak --system remote-delete flathub

echo "============== [E] 4.Install - Flatpak =============="
