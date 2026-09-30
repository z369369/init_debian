#!/bin/bash
echo "============== [S] [ 2-1 / 6 ] Install - apt =============="

sudo apt update
sudo apt -y autoremove
sudo apt autoclean
sudo apt -y upgrade

sudo apt -y --fix-broken install

sudo apt install -y flatpak git curl
echo "============== [E] [ 2-2 / 6 ] Install - apt =============="