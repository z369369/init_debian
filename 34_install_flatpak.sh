#!/bin/bash
echo "============== [S] 34.Install - Flatpak =============="

#by user
flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install -y --user flathub $(grep -vE "^\s*#" install.list | sed -e 's/#.*//'  | tr "\n" " " | cut -d '*' -f 2)

flatpak --system remote-delete flathub

echo "============== [E] 34.Install - Flatpak =============="