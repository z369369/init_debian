#!/bin/bash
echo -e "GET http://google.com HTTP/1.0\n\n" | nc google.com 80 > /dev/null 2>&1

if [ $? -eq 0 ]; then
    echo "Online..."
    ./1_remove_unuse.sh
    ./2_telemetry_off.sh
    ./3_install_ppa.sh
    ./4_install_apt.sh
    ./4_install_flatpak.sh
    ./5_setting.sh
    reboot
else
    echo "Offline... Please check Internet connection"
fi
