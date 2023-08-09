#!/bin/bash
echo "============== [S] [ 2-1 / 6 ] Install - apt =============="

sudo apt update
sudo apt -y autoremove
sudo apt autoclean
sudo apt -y upgrade

#sudo apt install --only-upgrade `apt upgrade | awk 'BEGIN{flag=0} /The following packages have been kept back:/ { flag=1} /^ /{if (flag) print}'`
#sudo apt install --only-upgrade `apt upgrade | awk 'BEGIN{flag=0} /다음 패키지를 과거 버전으로 유지합니다:/ { flag=1} /^ /{if (flag) print}'`

sudo apt-get install -y $(grep -vE "^\s*#" install_${1}.list | sed -e 's/#.*//'  | tr "\n" " " | cut -d '*' -f 1)

sudo apt -y autoremove

echo "============== [E] [ 2-1 / 6 ] Install - apt =============="

echo "============== [S] [ 2-2 / 6 ] Install - apt =============="

curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo install -o root -g root -m 644 microsoft.gpg /usr/share/keyrings/microsoft-archive-keyring.gpg
sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/usr/share/keyrings/microsoft-archive-keyring.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'

sudo apt-get install apt-transport-https
sudo apt-get update
sudo apt-get install code # or code-insiders

echo "============== [E] [ 2-2 / 6 ] Install - apt =============="


echo "============== [S] [ 2-3 / 6 ] Install - apt =============="

sudo apt update
sudo apt install -y flatpak
# sudo apt install -y gnome-software gnome-software-plugin-flatpak

echo "============== [E] [ 2-3 / 6 ] Install - apt =============="