#!/bin/bash
echo -e "GET http://google.com HTTP/1.0\n\n" | nc google.com 80 > /dev/null 2>&1

if [ $? -eq 0 ]; then
    echo "Online..."
    ./1_remove_unuse.sh
    ./2_pkg_custom.sh
    ./3_pkg_common.sh
    ./4_setting.sh
    ./5_telemetry_off.sh
    reboot
else
    echo "Offline... Please check Internet connection"
fi
