#!/bin/bash
#fupdate
flatpak update --noninteractive --assumeyes
flatpak uninstall --unused --noninteractive --assumeyes

rm -rf /home/lwh/.var/app/com.opera.Opera/config/opera/History