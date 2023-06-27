#!/bin/bash
echo "============== [S] [ 2-1 / 6 ] Install - apt =============="

sudo apt update
sudo apt -y autoremove
sudo apt autoclean
sudo apt -y upgrade

#vscode
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
rm -f packages.microsoft.gpg
sudo apt update && sudo apt -y upgrade
sudo apt install -y code

#sudo apt install --only-upgrade `apt upgrade | awk 'BEGIN{flag=0} /The following packages have been kept back:/ { flag=1} /^ /{if (flag) print}'`
#sudo apt install --only-upgrade `apt upgrade | awk 'BEGIN{flag=0} /다음 패키지를 과거 버전으로 유지합니다:/ { flag=1} /^ /{if (flag) print}'`

sudo apt-get install -y $(grep -vE "^\s*#" install.list | sed -e 's/#.*//'  | tr "\n" " " | cut -d '*' -f 1)

sudo apt -y autoremove

echo "============== [E] [ 2-1 / 6 ] Install - apt =============="

echo "============== [S] [ 2-2 / 6 ] Install - apt =============="

sudo apt update
sudo apt install -y flatpak
# sudo apt install -y gnome-software gnome-software-plugin-flatpak

echo "============== [E] [ 2-2 / 6 ] Install - apt =============="

