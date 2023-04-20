#!/bin/bash
echo "============== [S] 5.Link - shell, script =============="

ln -s ~/git/linux_init/script ~/script

rm -rf ~/.local/share/gnome-shell
ln -s ~/git/linux_init/gnome-shell ~/.local/share/gnome-shell

rm -rf ~/Templates
ln -s ~/git/linux_init/Templates ~/Templates

ln -s ~/.local/share/applications ~/Desktop/desktop_local
ln -s ~/.local/share/flatpak/exports/share/applications ~/Desktop/desktop_flatpak
ln -s /usr/share/applications ~/Desktop/desktop_usr

git clone https://github.com/cfgnunes/nautilus-scripts.git ~/.local/share/nautilus/scripts


rsync -a ~/git/linux_init/local_share/nautilus/ ~/.local/share/nautilus
rsync -a ~/git/linux_init/local_share/nautilus-python/ ~/.local/share/nautilus-python

echo "============== [E] 5.Link - shell, script =============="



echo "============== [S] 5.Nemo =============="

git clone https://github.com/Elagoht/nemo-copy-path ~/.local/share/nemo/actions
sudo apt install xclip

rm -rf ~/.local/share/nemo/scripts
ln -s ~/.local/share/nautilus/scripts ~/.local/share/nemo/scripts

echo "============== [E] 5.Nemo =============="



echo "============== [S] 5.Load - dconf_backup =============="

dconf load / < /home/$USER/git/linux_init/gnome-shell/dconf_backup

echo "============== [E] 5.Load - dconf_backup =============="



echo "============== [S] 5.Edit - Gnome Extension =============="

gsettings set org.gnome.GWeather temperature-unit centigrade
gsettings set org.gnome.shell disable-extension-version-validation true
gsettings set org.gnome.desktop.sound event-sounds false

echo "============== [E] 5.Link - Gnome Extension =============="



echo "============== [S] 5.Remove - Ubuntu ESM =============="

sudo mkdir /etc/apt/apt.conf.d/off
sudo mv /etc/apt/apt.conf.d/20apt-esm-hook.conf /etc/apt/apt.conf.d/off

echo "============== [S] 5.Remove - Ubuntu ESM =============="

# [backup] .config
# cd ~
# mv -f ~/linux_init/home/*.tar ~/
# tar xvf shell*.tar
# tar xvf config*.tar
# dconf load /org/gnome/ < ~/linux_init/home/dump_dconf_gnome
# gsettings set org.gnome.desktop.peripherals.keyboard numlock-state true

#if you want, ipv6 disable edit below
#sudo vi /etc/default/ufw 

#nautilus
# git clone https://github.com/angela-d/nautilus-right-click-new-file.git && cd nautilus-right-click-new-file
# ./automate.sh

# git clone https://github.com/cfgnunes/nautilus-scripts.git ~/.local/share/nautilus/scripts


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