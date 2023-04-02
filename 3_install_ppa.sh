#!/bin/bash
echo "============== [S] 3.Install - ppa =============="

sudo apt update && sudo apt -y upgrade
sudo apt -y autoremove
sudo apt install -y wget gpg ttf-mscorefonts-installer

#firefox
echo '
Package: snapd
Pin: release a=*
Pin-Priority: -10
' | sudo tee /etc/apt/preferences.d/no_snap 

echo '
Package: firefox*
Pin: release o=Ubuntu*
Pin-Priority: -1
' | sudo tee /etc/apt/preferences.d/firefox_no_snap

sudo add-apt-repository ppa:mozillateam/ppa
sudo apt update && sudo apt -y upgrade
sudo apt install -y firefox

#vscode
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
rm -f packages.microsoft.gpg
sudo apt update && sudo apt -y upgrade
sudo apt install -y code

sudo apt -y autoremove

#kernel
# sudo add-apt-repository ppa:cappelikan/ppa
# sudo apt install mainline

echo "============== [E] 3.Install - ppa =============="