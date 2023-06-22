#!/bin/bash
# Check if the user is in the sudo group
E_NOTROOT=87 # Non-root exit error.

## check if is sudoer
echo "[1/3]"
if ! $(sudo -l &> /dev/null); then
    echo "  root privileges are needed to run this script"
    echo "  User lwh should be in a sudo user group"
    echo ""
    echo "  su -"
    echo "  adduser lwh sudo"
    echo "  su - lwh"
    echo ""
    echo "  [FAIL] check upper message"
    exit $E_NOTROOT
else 
    echo "  Welcome sudo group user..."
fi

echo "[2/3]"
if [[ $(whoami) == "lwh" ]]; then
    echo "  Welcome lwh..."
else
    echo "  [FAIL] You are not lwh"
    exit
fi

echo "[3/3]" 
echo -e "GET http://google.com HTTP/1.0\n\n" | nc google.com 80 > /dev/null 2>&1

if [ $? -eq 0 ]; then
    echo "  Start custom installation..."
    ./13_install_apt.sh
    ./17_setting_firewall.sh
    ./24_install_flatpak.sh
    ./25_setting_custom.sh  
    ./31_remove_trash.sh
    echo "  [End] Complete - Need to Reboot"
else
    echo "  [FAIL] Please check Internet connection"
fi