#!/bin/bash
echo "============== [S] 1.Remove - APT package =============="

sudo apt remove --purge -y $(grep -vE "^\s*#" remove.list | sed -e 's/#.*//'  | tr "\n" " ")

echo "============== [E] 1.Remove - APT package =============="



echo "============== [S] 1.Remove - Ubuntu default extension =============="

sudo rm -rf /usr/share/gnome-shell/extensions/*

echo "============== [S] 1.Remove - Ubuntu default extension =============="