#!/bin/bash
echo "============== [S] Link - shell, script =============="
ln -s ~/git/linux_init/script ~/script

rm -rf ~/.local/share/gnome-shell
ln -s ~/git/linux_init/gnome-shell ~/.local/share/gnome-shell

rm -rf ~/Templates
ln -s ~/git/linux_init/Templates ~/Templates
echo "============== [E] Link - shell, script =============="


echo "============== [S] Link - hdd =============="
#root 
#backup_disk mount
sudo echo "UUID=fdcd9bf3-7e29-467b-926f-5fdd8c197a7d /media/lwh/backup_disk ext4 defaults 0 2" >> /etc/fstab
ln -s /media/lwh/backup_disk ~/Desktop/backup_disk
echo "============== [E] Link - hdd =============="

# [backup] .config
# cd ~
# mv -f ~/linux_init/home/*.tar ~/
# tar xvf shell*.tar
# tar xvf config*.tar
# dconf load /org/gnome/ < ~/linux_init/home/dump_dconf_gnome
# gsettings set org.gnome.desktop.peripherals.keyboard numlock-state true

# sudo ufw allow 1714:1764/tcp
# sudo ufw allow 1714:1764/udp
# sudo ufw allow 3389/tdp
# sudo ufw allow 3389/udp
# sudo ufw allow 22/tdp
# sudo ufw allow 22/udp
# sudo ufw reload

#nautilus
# git clone https://github.com/angela-d/nautilus-right-click-new-file.git && cd nautilus-right-click-new-file
# ./automate.sh

# git clone https://github.com/cfgnunes/nautilus-scripts.git ~/.local/share/nautilus/scripts
 