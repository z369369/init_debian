#!/bin/bash
echo "============== [S] 5.Link - shell, script =============="

ln -s ~/git/linux_init/script ~/script

rm -rf ~/.local/share/gnome-shell
ln -s ~/git/linux_init/gnome-shell ~/.local/share/gnome-shell

rm -rf ~/Templates
ln -s ~/git/linux_init/Templates ~/Templates

ln -s ~/.local/share/applications ~/Desktop/desktop_local
ln -s ~/.var/lib/flatpak/exports/share/applications ~/Desktop/desktop_flatpak
ln -s /usr/share/applications ~/Desktop/desktop_usr

echo "============== [E] 5.Link - shell, script =============="


echo "============== [S] 5.Edit - Gnome Extension =============="

gsettings set org.gnome.GWeather temperature-unit centigrade
gsettings set org.gnome.shell disable-extension-version-validation true

echo "============== [E] 5.Link - Gnome Extension =============="



# [backup] .config
# cd ~
# mv -f ~/linux_init/home/*.tar ~/
# tar xvf shell*.tar
# tar xvf config*.tar
# dconf load /org/gnome/ < ~/linux_init/home/dump_dconf_gnome
# gsettings set org.gnome.desktop.peripherals.keyboard numlock-state true

#if you want, ipv6 disable edit below
#sudo vi /etc/default/ufw 

#gsconnect
sudo ufw allow 1714:1764/tcp
sudo ufw allow 1714:1764/udp

#RDP
sudo ufw allow 3389/tcp
sudo ufw allow 3389/udp

sudo ufw allow 1022/tcp
sudo ufw allow 1022/udp

sudo ufw allow 5900/tcp
sudo ufw allow 5900/udp

#syncthing
sudo ufw allow 22000/tcp
sudo ufw allow 22000/udp
sudo ufw allow 21027/udp

sudo ufw reload

#nautilus
# git clone https://github.com/angela-d/nautilus-right-click-new-file.git && cd nautilus-right-click-new-file
# ./automate.sh

# git clone https://github.com/cfgnunes/nautilus-scripts.git ~/.local/share/nautilus/scripts

echo "============== [S] Syncthing Install =============="

echo "deb https://apt.syncthing.net/ syncthing stable" | sudo tee /etc/apt/sources.list.d/syncthing.list
curl -s https://syncthing.net/release-key.txt | sudo apt-key add -
sudo apt update
sudo apt install syncthing	
sudo systemctl enable syncthing@$USER.service
sudo systemctl start syncthing@$USER.service

echo "============== [E] Syncthing Install =============="


echo "============== [S] 5.Set Sudo key file =============="

echo "Check.. Sudo Key file Exist.."
if [ -e ~/.key ]; then
  echo "File .key already exists!"
else
  echo "Enter the Sudo password: "	
  read v_pwd
  echo $v_pwd >> ~/.key
  
echo "============== [E] 5.Set key file =============="