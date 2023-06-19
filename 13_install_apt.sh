#!/bin/bash
echo "============== [S] 13.Install - apt =============="

sudo apt update
sudo apt -y autoremove
sudo apt autoclean
sudo apt -y upgrade

#sudo apt install --only-upgrade `apt upgrade | awk 'BEGIN{flag=0} /The following packages have been kept back:/ { flag=1} /^ /{if (flag) print}'`
#sudo apt install --only-upgrade `apt upgrade | awk 'BEGIN{flag=0} /다음 패키지를 과거 버전으로 유지합니다:/ { flag=1} /^ /{if (flag) print}'`

sudo apt install -y $(grep -vE "^\s*#" install.list | sed -e 's/#.*//'  | tr "\n" " " | cut -d '*' -f 1)

sudo apt -y autoremove

echo "============== [E] 13.Install - apt =============="

echo "============== [S] 13.Install - Flatpak =============="

sudo apt update
sudo apt install -y flatpak
sudo apt install -y gnome-software-plugin-flatpak

echo "============== [S] 13.Install - Flatpak =============="

