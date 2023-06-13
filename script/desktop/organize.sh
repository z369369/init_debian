#!/bin/bash

#organize download folder
#Image Files
cd /home/lwh/Downloads

touch /home/lwh/Downloads

# Image Files
mv *.png *.jpg *.jpeg *.tif *.tiff *.bpm *.gif *.eps *.raw /home/lwh/Pictures 2> /dev/null

# Audio Files 
mv *.mp3 *.m4a *.flac *.aac *.ogg *.wav /home/lwh/Music 2> /dev/null

# Video Files 
mv *.mp4 *.mov *.avi *.mpg *.mpeg *.webm *.mpv *.mp2 *.wmv /home/lwh/Videos 2> /dev/null

# PDFs 
mv *.pdf *.doc *.ppt *.xls *.xlsx /home/lwh/Documents 2> /dev/null
mv *.txt *.ovpn /home/lwh/Downloads/Download_Home 2> /dev/null

# Scripts
mv *.py *.rb *.sh /home/lwh/git/linux_init/script 2> /dev/null

#Compressed Files
mv *.rar *.zip *.tar *.tar.gz *.7z *.deb *.AppImage *.flatpakref /home/lwh/Downloads/zip 2> /dev/null

# Iso
mv *.iso /home/lwh/Downloads/iso 2> /dev/null

rm *.ovpn 2> /dev/null
rm -rf /home/lwh/.config/google-chrome/Default/GPUCache
rm -rf /home/lwh/.var/app/com.usebottles.bottles/data/bottles/temp/*
#rsync -a --delete /home/http/ /media/lwh/lwh_backup1/http/

#obs not work
#https://unix.stackexchange.com/questions/552688/is-it-possible-to-roll-back-a-flatpak-update
#flatpak remote-info --log flathub com.obsproject.Studio
#cat /home/lwh/.key | sudo -S flatpak update -y --commit=694f40fda5aea03f5daf53db094cdcc5c29e62fa507d49d5bcfe399c55809ecd com.obsproject.Studio

rsync -a --delete --exclude-from /home/lwh --exclude .local/share/Trash --exclude .local/share/flatpak --exclude phone/Tachiyomi --exclude Games --exclude Downloads/iso --exclude .cache  /home/lwh/ /media/lwh/lwh_backup1/lwh/
cat /home/lwh/.key | sudo -S rsync -a --delete /etc/ /media/lwh/lwh_backup1/etc/

dconf dump / > /home/lwh/git/linux_init/gnome-shell/dconf_backup
#dconf load / < /home/lwh/git/linux_init/gnome-shell/dconf_backup