#!/bin/bash
echo "============== [S] [ 3 / 6 ] Install - flatpak =============="

#by user
flatpak --system remote-delete flathub

flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install -y --user flathub $(grep -vE "^\s*#" install_${1}.list | sed -e 's/#.*//'  | tr "\n" " " | cut -d '*' -f 2)
echo "============== [E] [ 3 / 6 ] Install - flatpak =============="