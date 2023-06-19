#!/bin/bash
echo "============== [S] 13.Install - apt =============="

apt update
apt -y autoremove
apt autoclean
apt -y upgrade

#apt install --only-upgrade `apt upgrade | awk 'BEGIN{flag=0} /The following packages have been kept back:/ { flag=1} /^ /{if (flag) print}'`
#apt install --only-upgrade `apt upgrade | awk 'BEGIN{flag=0} /다음 패키지를 과거 버전으로 유지합니다:/ { flag=1} /^ /{if (flag) print}'`

apt install -y $(grep -vE "^\s*#" install.list | sed -e 's/#.*//'  | tr "\n" " " | cut -d '*' -f 1)

apt -y autoremove

echo "============== [E] 13.Install - apt =============="

echo "============== [S] 13.Install - Flatpak =============="

apt update
apt install -y flatpak
apt install -y gnome-software-plugin-flatpak

echo "============== [S] 13.Install - Flatpak =============="

