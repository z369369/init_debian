#!/bin/bash
echo -e "GET http://google.com HTTP/1.0\n\n" | nc google.com 80 > /dev/null 2>&1

if [ $? -eq 0 ]; then
    echo "Start custom installation"
    ./11_remove_trash.sh
    ./13_install_apt.sh
    ./13_install_apt.sh
    ./17_setting_firewall.sh
else
    echo "Please check Internet connection"
fi
