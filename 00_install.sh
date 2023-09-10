#!/bin/bash
echo "============== [S] [ 1-1 / 6 ] Prepare =============="

echo -e "GET http://google.com HTTP/1.0\n\n" | nc google.com 80 > /dev/null 2>&1

if [ $? -eq 0 ]; then
    echo "Online"
else
    echo "Offline"
    exit
fi

read -p "Choose install mode.. [ (N)ormal / (M)inimal ] : " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Nn]$ ]]; then
    echo -e "  Start \033[33mNormal\033[m install..."
    ./02_apt.sh normal
    ./02_apt_normal.sh
    ./03_flatpak.sh normal
    ./04_firewall.sh
    ./05_custom.sh $(whoami)
    ./06_custom_link.sh $(whoami)
    ./07_remove_trash.sh
fi 

if [[ $REPLY =~ ^[Mm]$ ]]; then
    echo -e "  Start \033[32mMinimal\033[m install..."
    ./02_apt.sh minimal
    ./03_flatpak.sh minimal
    ./04_firewall.sh
    ./15_custom.sh $(whoami)
    ./07_remove_trash.sh
fi
echo "  All done!! Need to Reboot"