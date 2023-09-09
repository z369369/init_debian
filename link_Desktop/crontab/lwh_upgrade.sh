#!/bin/bash
flatpak update --noninteractive --assumeyes
flatpak uninstall --unused --noninteractive --assumeyes

rm -rf /home/lwh/.var/app/com.opera.Opera/config/opera/History

/home/lwh/.local/bin/gupdate > /dev/null 2>&1