#!/bin/bash
echo "============== [S] 4.Install - apt =============="

sudo apt-get update && sudo apt-get -y upgrade
sudo apt-get install -y $(cat pkg_install_apt)
sudo apt -y autoremove
sudo deborphan | xargs sudo apt-get -y remove --purge

echo "============== [E] 4.Install - apt =============="

