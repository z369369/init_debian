#!/bin/bash
echo -e "GET http://google.com HTTP/1.0\n\n" | nc google.com 80 > /dev/null 2>&1

# Check if the user is in the sudo group
E_NOTROOT=87 # Non-root exit error.

## check if is sudoer
if ! $(sudo -l &> /dev/null); then
    echo "[1/3] root privileges are needed to run this script"
    echo "  User lwh should be in a sudo user group"
    echo ""
    echo "  su -"
    echo "  adduser lwh sudo"
    echo "  su - lwh"
    echo "  "
    exit $E_NOTROOT
else 
    echo "[1/3] Welcome sudo group user..."
fi

if [[ $(whoami) == "lwh" ]]; then
    echo "[2/3] Welcome lwh..."
else
    echo "[2/3] You are not lwh"
    exit
fi

if [ $? -eq 0 ]; then
    echo "[3/3] Start custom installation..."
    ./11_remove_trash.sh
    ./13_install_apt.sh
    ./17_setting_firewall.sh
    ./34_install_flatpak.sh
    ./35_setting_custom.sh    
else
    echo "[3/3] Please check Internet connection"
fi
