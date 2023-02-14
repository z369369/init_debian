#!/bin/bash

#organize download folder
#Image Files
cd ~/Downloads

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
mv *.rar *.zip *.tar *.tar.gz *.7z *.deb ~/Downloads/zip

# Iso
mv *.iso ~/Downloads/iso

rm -rf /media/lwh/backup_disk/home/lwh

mkdir /media/lwh/backup_disk/home/lwh

rsync -a --exclude-from /home/lwh --exclude Games --exclude Public --exclude Downloads --exclude .cache --exclude .var  /home/lwh/ /media/lwh/backup_disk/home/lwh/

notify-send 'Complete' 'Organizing your downloads Folder'
