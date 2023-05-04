#!/bin/bash
echo -e "GET http://google.com HTTP/1.0\n\n" | nc google.com 80 > /dev/null 2>&1

if [ $? -eq 0 ]; then
    echo "Start custom installation"
    ./1_remove_trash.sh
    ./2_telemetry_off.sh
    ./5_setting_custom.sh
    reboot
else
    echo "Please check Internet connection"
fi