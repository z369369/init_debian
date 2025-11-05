#!/bin/bash

#mpv
git clone https://github.com/9beach/mpv-config.git ~/.config/mpv
sed -i 's/subcp=utf8:cp949//' ~/.config/mpv/mpv.conf
sed -i '1s/^/screenshot-directory=~\/Pictures\/mpv\n/' ~/.config/mpv/mpv.conf
sed -i '1s/^/ontop=yes\n/' ~/.config/mpv/mpv.conf
sed -i '1s/^/on-all-workspaces=yes\n/' ~/.config/mpv/mpv.conf

git clone https://github.com/Elagoht/nemo-copy-path ~/.local/share/nemo/actions

echo "============== [S] [5-2 / 6] Service =============="

sudo systemctl enable syncthing@lwh.service

echo "============== [E] [5-2 / 6] Service =============="

rsync -a ~/git/init_debian/copy/home/lwh/ ~/

echo "============== [E] [5-4 / 6] Dconf restore =============="

sh -c "sudo sed -i 's/lwh/$1/g' ~/git/init_debian/gnome-shell/dconf_backup"
dconf load / < ~/git/init_debian/gnome-shell/dconf_backup

echo "============== [E] [5-4 / 6] Dconf restore =============="

echo "============== [S] [5-5 / 6] install font =============="
mkdir ~/.fonts
cd ~/.fonts
wget https://github.com/naver/d2codingfont/releases/download/VER1.3.2/D2Coding-Ver1.3.2-20180524.zip
unzip D2Coding-Ver1.3.2-20180524.zip
sudo fc-cache -f -v
echo "============== [S] [5-5 / 6] install font =============="

echo "============== [S] [5-6 / 6] Set Sudo key file =============="

echo "Check.. Sudo Key file Exist.."
if [ -e ~/.key ]; then
  echo "File .key already exists!"
else
  echo "Enter the Sudo password: "	
  read v_pwd
  echo $v_pwd >> ~/.key
fi

echo "============== [E] [5-6 / 6] Set key file =============="

