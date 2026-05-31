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


rsync -a --delete ~/.bash* /media/lwh/lwh_backup
rsync -a --delete ~/.conkyrc /media/lwh/lwh_backup
rsync -a --delete ~/.config /media/lwh/lwh_backup
rsync -a --delete ~/.key /media/lwh/lwh_backup
rsync -a --delete ~/.mozilla /media/lwh/lwh_backup
rsync -a --delete ~/.ssh /media/lwh/lwh_backup
rsync -a --delete ~/.xfce4 /media/lwh/lwh_backup
rsync -a --delete ~/.xprofile /media/lwh/lwh_backup

rsync -a --delete ~/.fonts /media/lwh/lwh_backup
rsync -a --delete ~/.icons /media/lwh/lwh_backup
rsync -a --delete ~/.themes /media/lwh/lwh_backup

rsync -a --delete ~/Desktop /media/lwh/lwh_backup
rsync -a --delete ~/git /media/lwh/lwh_backup
rsync -a --delete ~/phone /media/lwh/lwh_backup
rsync -a --delete ~/Downloads/program* /media/lwh/lwh_backup/Downloads

#rsync -av --progress --dry-run \
rsync -a --delete \
--exclude='share/Trash/' \
--exclude='share/flatpak/' \
~/.local/ /media/lwh/lwh_backup/.local

cat ~/.key | sudo -S rsync -a --delete /etc/ /media/lwh/lwh_backup/etc/

#python
python3 ~/Desktop/bin/pyauto/dup_remove.py

notify-send '파일 정리' '파일 정리가 완료되었습니다!'
