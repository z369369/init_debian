#!/bin/bash
echo "============== [S] 11.Remove - APT package =============="

sudo apt remove --purge -y $(grep -vE "^\s*#" remove.list | sed -e 's/#.*//'  | tr "\n" " ")

echo "============== [E] 11.Remove - APT package =============="



echo "============== [S] 11.Remove - Ubuntu default extension =============="

sudo rm -rf /usr/share/gnome-shell/extensions/*

echo "============== [S] 11.Remove - Ubuntu default extension =============="

sudo systemctl disable NetworkManager-wait-online.service
sudo systemctl disable systemd-timesyncd.service