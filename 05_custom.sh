#!/bin/bash
echo "============== [S] [5-1 / 6] Link - shell, script =============="
rm -rf ~/script
ln -s ~/git/init_debian/script ~/script

rm -rf ~/.local/share/gnome-shell
ln -s ~/git/init_debian/gnome-shell ~/.local/share/gnome-shell

rm -rf ~/Templates
ln -s ~/git/init_debian/Templates ~/Templates

rm -rf ~/Desktop/desktop_local
ln -s ~/.local/share/applications ~/Desktop/desktop_local

rm -rf ~/Desktop/desktop_flatpak
ln -s ~/.local/share/flatpak/exports/share/applications ~/Desktop/desktop_flatpak

rm -rf ~/Desktop/desktop_usr
ln -s /usr/share/applications ~/Desktop/desktop_usr

rm -rf "/home/lwh/Pictures/스크린샷"
ln -s /home/lwh/Pictures/Screenshots "/home/lwh/Pictures/스크린샷"

rm -rf ~/.local/share/nautilus/scripts
git clone https://github.com/cfgnunes/nautilus-scripts.git ~/.local/share/nautilus/scripts

#mpv
git clone https://github.com/9beach/mpv-config.git ~/.config/mpv
sed -i 's/subcp=utf8:cp949//' ~/.config/mpv/mpv.conf

sed -i '1s/^/screenshot-directory=~\/Pictures\/mpv\n/' ~/.config/mpv/mpv.conf
sed -i '1s/^/ontop=yes\n/' ~/.config/mpv/mpv.conf
sed -i '1s/^/on-all-workspaces=yes\n/' ~/.config/mpv/mpv.conf

cp -rf ~/git/init_debian/copy_local_share/* ~/.local/share/

sudo systemctl enable syncthing@lwh.service

echo "============== [E] [5-1 / 6] Link - shell, script =============="

echo "============== [S] [5-2 / 6] Nemo =============="

git clone https://github.com/Elagoht/nemo-copy-path ~/.local/share/nemo/actions

rm -rf ~/.local/share/nemo/scripts
ln -s ~/.local/share/nautilus/scripts ~/.local/share/nemo/scripts

echo "============== [E] [5-2 / 6] Nemo =============="

echo "============== [S] [5-3 / 6] Edit - Gnome Extension =============="

gsettings set org.gnome.GWeather temperature-unit centigrade
gsettings set org.gnome.shell disable-extension-version-validation true
gsettings set org.gnome.desktop.sound event-sounds false

gsettings set org.gnome.desktop.peripherals.keyboard numlock-state true
gsettings set org.gnome.desktop.peripherals.keyboard remember-numlock-state true

gsettings set org.gnome.SessionManager logout-prompt false
gsettings set org.gnome.desktop.interface enable-animations false

gsettings set org.gnome.shell.extensions.stocks.ticker-interval 600

echo "============== [E] [5-3 / 6] Link - Gnome Extension =============="

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

