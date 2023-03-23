#!/bin/bash
echo "============== [S] Link - shell, script =============="
ln -s ~/git/linux_init/script ~/script

rm -rf ~/.local/share/gnome-shell
ln -s ~/git/linux_init/gnome-shell ~/.local/share/gnome-shell

rm -rf ~/Templates
ln -s ~/git/linux_init/Templates ~/Templates

ln -s ~/.local/share/applications ~/Desktop/desktop_local
ln -s ~/.var/lib/flatpak/exports/share/applications ~/Desktop/desktop_flatpak
ln -s /usr/share/applications ~/Desktop/desktop_usr
echo "============== [E] Link - shell, script =============="

echo "============== [S] Edit - Gnome Extension =============="
gsettings set org.gnome.GWeather temperature-unit centigrade
gsettings set org.gnome.shell disable-extension-version-validation true
echo "============== [E] Link - Gnome Extension =============="

echo "============== [S] Remove - ubuntu ESM =============="
sudo mkdir /etc/apt/apt.conf.d/off
sudo mv /etc/apt/apt.conf.d/20apt-esm-hook.conf /etc/apt/apt.conf.d/off
echo "============== [S] Remove - ubuntu ESM =============="

# [backup] .config
# cd ~
# mv -f ~/linux_init/home/*.tar ~/
# tar xvf shell*.tar
# tar xvf config*.tar
# dconf load /org/gnome/ < ~/linux_init/home/dump_dconf_gnome
# gsettings set org.gnome.desktop.peripherals.keyboard numlock-state true

#if you want, ipv6 disable edit below
#sudo vi /etc/default/ufw 
sudo ufw allow 1714:1764/tcp
sudo ufw allow 1714:1764/udp

sudo ufw allow 3389/tcp
sudo ufw allow 3389/udp

sudo ufw allow 1022/tcp
sudo ufw allow 1022/udp

sudo ufw allow 5900/tcp
sudo ufw allow 5900/udp

sudo ufw allow 22000/tcp
sudo ufw allow 22000/udp
sudo ufw allow 21027/udp

sudo ufw allow 22/tcp
sudo ufw allow 22/udp
sudo ufw reload

#nautilus
# git clone https://github.com/angela-d/nautilus-right-click-new-file.git && cd nautilus-right-click-new-file
# ./automate.sh

# git clone https://github.com/cfgnunes/nautilus-scripts.git ~/.local/share/nautilus/scripts

echo "============== [S] syncth Install =============="
echo "deb https://apt.syncthing.net/ syncthing stable" | sudo tee /etc/apt/sources.list.d/syncthing.list
curl -s https://syncthing.net/release-key.txt | sudo apt-key add -
sudo apt update
sudo apt install syncthing	
sudo systemctl enable syncthing@$USER.service
sudo systemctl start syncthing@$USER.service
echo "============== [E] syncth Install =============="

echo "============== [S] Set key file =============="
echo "Check.. Key file Exist.."
if [ -e ~/.key ]; then
  echo "File .key already exists!"
else
  echo "Enter the Sudo password: "	
  read v_pwd
  echo $v_pwd >> ~/.key
echo "============== [E] Set key file =============="