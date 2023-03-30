#!/bin/bash
echo "============== [S] 4.Install - apt =============="

sudo apt-get install -y $(cat pkg_install_apt)
sudo apt-get update && sudo apt-get -y upgrade
sudo apt autoremove

echo "============== [E] 4.Install - apt =============="

