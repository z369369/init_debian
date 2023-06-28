#!/bin/bash

#organize download folder
#Image Files
cd ~/Downloads

touch ~/Downloads

# Image Files
mv *.png *.jpg *.jpeg *.tif *.tiff *.bpm *.gif *.eps *.raw ~/Pictures 2> /dev/null

# Audio Files 
mv *.mp3 *.m4a *.flac *.aac *.ogg *.wav ~/Music 2> /dev/null

# Video Files 
mv *.mp4 *.mov *.avi *.mpg *.mpeg *.webm *.mpv *.mp2 *.wmv ~/Videos 2> /dev/null

# PDFs 
mv *.pdf *.doc *.ppt *.xls *.xlsx ~/Documents 2> /dev/null
mv *.txt *.ovpn ~/Downloads/Download_Home 2> /dev/null

# Scripts
mv *.py *.rb *.sh ~/git/init_debian/script 2> /dev/null

#Compressed Files
mv *.rar *.zip *.tar *.tar.gz *.7z *.deb *.AppImage *.flatpakref ~/Downloads/zip 2> /dev/null

# Iso
mv *.iso ~/Downloads/iso 2> /dev/null

rm *.ovpn 2> /dev/null
rm -rf ~/.config/google-chrome/Default/GPUCache
rm -rf ~/.var/app/com.usebottles.bottles/data/bottles/temp/*
#rsync -a --delete /home/http/ /media/lwh/lwh_backup1/http/

#obs not work
#https://unix.stackexchange.com/questions/552688/is-it-possible-to-roll-back-a-flatpak-update
#flatpak remote-info --log flathub com.obsproject.Studio
#cat ~/.key | sudo -S flatpak update -y --commit=694f40fda5aea03f5daf53db094cdcc5c29e62fa507d49d5bcfe399c55809ecd com.obsproject.Studio

cat ~/.key | sudo -S rsync -a --delete --exclude-from /home/lwh --exclude .var/app/org.gnome.Boxes --exclude .local/share/Trash --exclude .local/share/flatpak --exclude phone/Tachiyomi --exclude Games --exclude Downloads/iso --exclude .cache  ~/ /media/lwh/lwh_backup1/lwh/
cat ~/.key | sudo -S rsync -a --delete /etc/ /media/lwh/lwh_backup1/etc/

dconf dump / > ~/git/init_debian/gnome-shell/dconf_backup
#dconf load / < ~/git/init_debian/gnome-shell/dconf_backup