#!/bin/bash
echo "============== [S] [ 3 / 6 ] Install - flatpak =============="

#by user
sudo flatpak --system remote-delete flathub

flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

sudo flatpak remote-delete --system flathub

echo "============== [E] [ 3 / 6 ] Install - flatpak =============="