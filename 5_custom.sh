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

git clone https://github.com/cfgnunes/nautilus-scripts.git ~/.local/share/nautilus/scripts


rsync -a ~/git/init_debian/local_share/nautilus/ ~/.local/share/nautilus
rsync -a ~/git/init_debian/local_share/nautilus-python/ ~/.local/share/nautilus-python

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

echo "============== [E] [5-3 / 6] Link - Gnome Extension =============="

echo "============== [E] [5-4 / 6] Dconf restore =============="

sh -c "sudo sed -i 's/lwh/$1/g' ~/git/init_debian/gnome-shell/dconf_backup"
dconf load / < ~/git/init_debian/gnome-shell/dconf_backup

echo "============== [E] [5-4 / 6] Dconf restore =============="

echo "============== [S] [5-5 / 6] Set Sudo key file =============="

echo "Check.. Sudo Key file Exist.."
if [ -e ~/.key ]; then
  echo "File .key already exists!"
else
  echo "Enter the Sudo password: "	
  read v_pwd
  echo $v_pwd >> ~/.key
fi

echo "============== [E] [5-5 / 6] Set key file =============="


#vscode
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
rm -f packages.microsoft.gpg
sudo apt update && sudo apt -y upgrade
sudo apt install -y code
