#!/bin/bash
echo "============== [S] 5.Link - shell, script =============="
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

rm -rf ~/Games
ln -s /media/lwh/lwh_backup1/lwh/Games ~/Games

git clone https://github.com/cfgnunes/nautilus-scripts.git ~/.local/share/nautilus/scripts


rsync -a ~/git/init_debian/local_share/nautilus/ ~/.local/share/nautilus
rsync -a ~/git/init_debian/local_share/nautilus-python/ ~/.local/share/nautilus-python

echo "============== [E] 5.Link - shell, script =============="

echo "============== [S] 5.Nemo =============="

git clone https://github.com/Elagoht/nemo-copy-path ~/.local/share/nemo/actions
sudo apt install xclip

rm -rf ~/.local/share/nemo/scripts
ln -s ~/.local/share/nautilus/scripts ~/.local/share/nemo/scripts

echo "============== [E] 5.Nemo =============="



echo "============== [S] 5.Load - dconf_backup =============="

dconf load / < /home/$USER/git/init_debian/gnome-shell/dconf_backup

echo "============== [E] 5.Load - dconf_backup =============="



echo "============== [S] 5.Edit - Gnome Extension =============="

gsettings set org.gnome.GWeather temperature-unit centigrade
gsettings set org.gnome.shell disable-extension-version-validation true
gsettings set org.gnome.desktop.sound event-sounds false

echo "============== [E] 5.Link - Gnome Extension =============="

echo "============== [S] 5.Set Sudo key file =============="

echo "Check.. Sudo Key file Exist.."
if [ -e ~/.key ]; then
  echo "File .key already exists!"
else
  echo "Enter the Sudo password: "	
  read v_pwd
  echo $v_pwd >> ~/.key
fi

echo "============== [E] 5.Set key file =============="