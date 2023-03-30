#!/bin/bash
echo "============== [S] 3.Install - ppa =============="
sudo apt -y autoremove
sudo apt-get install -y wget gpg

#vscode
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
rm -f packages.microsoft.gpg
sudo apt-get update && sudo apt-get -y upgrade
sudo apt install -y code

#chrome
wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://dl.google.com/linux/chrome/deb/ stable main"
sudo apt-get update && sudo apt-get -y upgrade
sudo apt install -y google-chrome-stable

#firefox
sudo add-apt-repository ppa:mozillateam/ppa

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

sudo apt-get update && sudo apt-get -y upgrade
sudo apt install firefox

#kernel
# sudo add-apt-repository ppa:cappelikan/ppa
# sudo apt install mainline

echo "============== [E] 3.Install - ppa =============="
