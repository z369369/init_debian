#!/bin/bash

#organize download folder
#Image Files
cd ~/Downloads

rm *.ovpn

# Image Files
mv *.png *.jpg *.jpeg *.tif *.tiff *.bpm *.gif *.eps *.raw ~/Pictures

# Audio Files 
mv *.mp3 *.m4a *.flac *.aac *.ogg *.wav ~/Music

# Video Files 
mv *.mp4 *.mov *.avi *.mpg *.mpeg *.webm *.mpv *.mp2 *.wmv ~/Videos

# PDFs 
mv *.pdf *.doc *.txt *.ppt *.xls *.xlsx *.ovpn ~/Documents

# Scripts
mv *.py *.rb *.sh ~/git/linux_init/script

#Compressed Files
mv *.rar *.zip *.tar *.tar.gz *.7z *.deb *.AppImage ~/Downloads/zip

# Iso
mv *.iso ~/Downloads/iso

#rm -rf /media/$USER/backup_disk/home/$USER
#mkdir /media/$USER/backup_disk/home/$USER

#obs not work
#https://unix.stackexchange.com/questions/552688/is-it-possible-to-roll-back-a-flatpak-update
#flatpak remote-info --log flathub com.obsproject.Studio
#cat ~/.key | sudo -S flatpak update -y --commit=694f40fda5aea03f5daf53db094cdcc5c29e62fa507d49d5bcfe399c55809ecd com.obsproject.Studio

rsync -a --exclude-from /home/$USER --exclude phone --exclude Games --exclude Public --exclude Downloads --exclude .cache --exclude .var  /home/$USER/ /media/$USER/backup_disk/home/$USER/

notify-send 'Complete' 'Organizing your downloads Folder'
