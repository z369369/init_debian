#!/bin/bash
echo "============== [S] [ 1-1 / 6 ] Prepare =============="

sudo apt -y install netcat-openbsd

echo -e "GET http://google.com HTTP/1.0\n\n" | nc google.com 80 > /dev/null 2>&1

if [ $? -eq 0 ]; then
    echo "Online"
else
    echo "Offline"
    exit
fi

echo -e "  Start Install..."
./02_apt1.sh
./02_apt2.sh
./03_flatpak.sh
./04_firewall.sh
./05_custom.sh $(whoami)
./06_custom_link.sh $(whoami)
./07_remove_trash.sh

echo "  All done!! Need to Reboot"
