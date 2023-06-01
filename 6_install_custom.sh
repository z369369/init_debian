#!/bin/bash
echo "============== [S] 6.Install - ppa =============="

sudo apt update && sudo apt -y upgrade
sudo apt -y autoremove
sudo apt install -y wget gpg 

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

echo "============== [E] 6.Install - ppa =============="



echo "============== [S] 6.Install - Syncthing =============="

sudo curl -s -o /usr/share/keyrings/syncthing-archive-keyring.gpg https://syncthing.net/release-key.gpg
echo "deb [signed-by=/usr/share/keyrings/syncthing-archive-keyring.gpg] https://apt.syncthing.net/ syncthing stable" | sudo tee /etc/apt/sources.list.d/syncthing.list
sudo apt update
sudo apt install -y syncthing	
sudo systemctl enable syncthing@$USER.service
sudo systemctl start syncthing@$USER.service

echo "============== [E] 6.Install - Syncthing =============="



# echo "============== [S] 6.Install - Chrome =============="

# curl -fSsL https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor | sudo tee /usr/share/keyrings/google-chrome.gpg > /dev/null
# echo deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main | sudo tee /etc/apt/sources.list.d/google-chrome.list
# sudo apt update && sudo apt -y upgrade
# sudo apt install -y google-chrome-stable

# echo "============== [E] 6.Install - Chrome =============="