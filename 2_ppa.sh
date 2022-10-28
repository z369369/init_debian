#!/bin/bash
echo "============== [S] Install - ppa =============="

#vscode
sudo apt-get install -y wget gpg
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
rm -f packages.microsoft.gpg
sudo apt install -y code

#chrome
wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
yes '' | sudo add-apt-repository "deb [arch=amd64] https://dl.google.com/linux/chrome/deb/ stable main" 
sudo apt install -y google-chrome-stable

#opera
wget -qO- https://deb.opera.com/archive.key | sudo apt-key add -
yes '' | sudo add-apt-repository "deb [arch=i386,amd64] https://deb.opera.com/opera-stable/ stable non-free"
sudo apt install -y opera-stable

##copyq
# yes '' | sudo add-apt-repository -y ppa:hluk/copyq
# sudo apt install -y copyq

echo "============== [E] Install - ppa =============="
