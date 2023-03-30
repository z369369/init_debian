#!/bin/bash
echo "============== [S] 4.Install - apt =============="
sudo apt update && sudo apt -y upgrade
sudo apt install -y $(cat pkg_install_apt)
sudo apt -y autoremove
sudo deborphan | xargs sudo apt -y remove --purge

echo "============== [E] 4.Install - apt =============="

