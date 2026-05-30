#!/bin/bash

#organize download folder
#Image Files
cd ~/Downloads

# Image Files
mv *.nsp *.xci /media/lwh/lwh_backup/Games/nintendo_nsp 2> /dev/null

# Image Files
mv *.png *.jpg *.jpeg *.tif *.tiff *.bpm *.gif *.eps *.raw "~/Pictures/Screenshots" 2> /dev/null

# Audio Files 
mv *.mp3 *.m4a *.flac *.aac *.ogg *.wav ~/Music 2> /dev/null

# Video Files 
mv *.mp4 *.mov *.avi *.mpg *.mpeg *.webm *.mpv *.mp2 *.wmv ~/Videos 2> /dev/null

# PDFs 
mv *.pdf *.doc *.ppt *.xls *.xlsx ~/Documents 2> /dev/null

# Iso
mv *.iso ~/Downloads/iso 2> /dev/null


rsync -a ~/.bash* /media/lwh/lwh_backup
rsync -a ~/.conkyrc /media/lwh/lwh_backup
rsync -a ~/.config /media/lwh/lwh_backup
rsync -a ~/.key /media/lwh/lwh_backup
rsync -a ~/.mozilla /media/lwh/lwh_backup
rsync -a ~/.ssh /media/lwh/lwh_backup
rsync -a ~/.xfce4 /media/lwh/lwh_backup
rsync -a ~/.xprofile /media/lwh/lwh_backup

rsync -a ~/.fonts /media/lwh/lwh_backup
rsync -a ~/.icons /media/lwh/lwh_backup
rsync -a ~/.themes /media/lwh/lwh_backup

rsync -a ~/Desktop /media/lwh/lwh_backup
rsync -a ~/git /media/lwh/lwh_backup
rsync -a ~/phone /media/lwh/lwh_backup
rsync -a ~/Downloads/program* /media/lwh/lwh_backup/Downloads

#rsync -av --progress --dry-run \
rsync -a \
--exclude='share/Trash/' \
--exclude='share/flatpak/' \
~/.local/ /media/lwh/lwh_backup/.local


#obs not work
#https://unix.stackexchange.com/questions/552688/is-it-possible-to-roll-back-a-flatpak-update
#flatpak remote-info --log flathub com.obsproject.Studio
#cat ~/.key | sudo -S flatpak update -y --commit=694f40fda5aea03f5daf53db094cdcc5c29e62fa507d49d5bcfe399c55809ecd com.obsproject.Studio


cat ~/.key | sudo -S rsync -a --delete /etc/ /media/lwh/lwh_backup/etc/

#dconf dump / > ~/git/init_debian/gnome-shell/dconf_backup
#dconf load / < ~/git/init_debian/gnome-shell/dconf_backup

#python
python3 ~/Desktop/bin/pyauto/dup_remove.py

notify-send '파일 정리' '파일 정리가 완료되었습니다!'
