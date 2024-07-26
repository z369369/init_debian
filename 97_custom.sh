#!/bin/bash
rm -rf ~/.local/share/nautilus/scripts
git clone https://github.com/cfgnunes/nautilus-scripts.git ~/.local/share/nautilus/scripts

echo "============== [S] [5-3 / 6] Edit - Gnome Extension =============="

gsettings set org.gnome.GWeather temperature-unit centigrade
gsettings set org.gnome.shell disable-extension-version-validation true
gsettings set org.gnome.desktop.sound event-sounds false

gsettings set org.gnome.desktop.peripherals.keyboard numlock-state true
gsettings set org.gnome.desktop.peripherals.keyboard remember-numlock-state true

gsettings set org.gnome.SessionManager logout-prompt false
gsettings set org.gnome.desktop.interface enable-animations false

gsettings set org.gnome.shell.extensions.stocks.ticker-interval 600

echo "============== [E] [5-3 / 6] Edit - Gnome Extension =============="

echo "============== [E] [5-4 / 6] Dconf restore =============="

sh -c "sudo sed -i 's/lwh/$1/g' ~/git/init_debian/gnome-shell/dconf_backup"
dconf load / < ~/git/init_debian/gnome-shell/dconf_backup

echo "============== [E] [5-4 / 6] Dconf restore =============="

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

