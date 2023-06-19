#!/bin/bash
su -

echo -e "GET http://google.com HTTP/1.0\n\n" | nc google.com 80 > /dev/null 2>&1

if [ $? -eq 0 ]; then
    echo "Start custom installation"
    ./11_root_remove_trash.sh
    ./35_setting_custom.sh
    reboot
else
    echo "Please check Internet connection"
fi
