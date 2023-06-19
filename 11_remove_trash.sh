#!/bin/bash
su -

echo "============== [S] 11.Remove - APT package =============="

apt remove --purge -y $(grep -vE "^\s*#" remove.list | sed -e 's/#.*//'  | tr "\n" " ")

echo "============== [E] 11.Remove - APT package =============="



echo "============== [S] 11.Remove - Ubuntu default extension =============="

rm -rf /usr/share/gnome-shell/extensions/*

echo "============== [S] 11.Remove - Ubuntu default extension =============="

systemctl disable NetworkManager-wait-online.service
systemctl disable systemd-timesyncd.service