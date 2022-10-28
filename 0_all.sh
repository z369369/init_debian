#!/bin/bash
echo "============== [S] Init - Download =============="
sudo apt install git
mkdir ~/git
cd ~/git
git clone https://github.com/ppp821203/linux_init.git
chmod -R 777 ~/git
cd linux_init
echo "============== [E] Init - Download =============="

./1_delsnap.sh
./2_ppa.sh
./3_package.sh
./4_link.sh
reboot