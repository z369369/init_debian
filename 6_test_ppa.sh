#!/bin/bash
echo "============== [S] Syncthing Install =============="

sudo curl -s -o /usr/share/keyrings/syncthing-archive-keyring.gpg https://syncthing.net/release-key.gpg
echo "deb [signed-by=/usr/share/keyrings/syncthing-archive-keyring.gpg] https://apt.syncthing.net/ syncthing stable" | sudo tee /etc/apt/sources.list.d/syncthing.list
sudo apt update
sudo apt install -y syncthing	
sudo systemctl enable syncthing@$USER.service
sudo systemctl start syncthing@$USER.service

echo "============== [E] Syncthing Install =============="



echo "============== [S] Chrome Install =============="

curl -fSsL https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor | sudo tee /usr/share/keyrings/google-chrome.gpg > /dev/null
echo deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main | sudo tee /etc/apt/sources.list.d/google-chrome.list
sudo apt update && sudo apt -y upgrade
sudo apt install -y google-chrome-stable

echo "============== [E] Chrome Install =============="