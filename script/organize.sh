#!/bin/bash

#Create Folders
#Image Files
cd ~/Downloads


mv *.png *.jpg *.jpeg *.tif *.tiff *.bpm *.gif *.eps *.raw ~/Pictures

# Audio Files 
mv *.mp3 *.m4a *.flac *.aac *.ogg *.wav ~/Musics

# Video Files 
mv *.mp4 *.mov *.avi *.mpg *.mpeg *.webm *.mpv *.mp2 *.wmv ~/Videos

# PDFs 
mv *.pdf *.doc *.ppt *.xls *.xlsx ~/Documents

# Scripts
mv *.py *.rb *.sh ~/git/linux_init/script

#Compressed Files
mv *.rar *.zip *.tar *.tar.gz *.7z ~/Downloads/zip

# Scripts
mv *.iso ~/Downloads/iso

notify-send 'Complete' 'Organizing your downloads Folder'
