#!/bin/bash
# Check if the user is in the sudo group
E_NOTROOT=87 # Non-root exit error.

## check if is sudoer
echo "[1/6]"
if ! $(sudo -l &> /dev/null); then
    echo "  root privileges are needed to run this script"
    echo "  This user should be in a sudo user group"
    echo ""
    echo "  su -"
    echo "  adduser [username] sudo"
    echo "  su - [username]"
    echo ""
    echo "  [FAIL] check upper message"
    exit $E_NOTROOT
else 
    echo "  Welcome sudo group user..."
fi

echo "[1/6]" 
echo -e "GET http://google.com HTTP/1.0\n\n" | nc google.com 80 > /dev/null 2>&1

if [ $? -eq 0 ]; then
    echo "  Start custom installation..."
    # ./2_apt.sh
    # ./3_flatpak.sh
    # ./4_firewall.sh
    ./5_custom.sh $(whoami)
    # ./6_remove_trash.sh
    echo "  [End] Complete - Need to Reboot"
else
    echo "  [FAIL] Please check Internet connection"
fi