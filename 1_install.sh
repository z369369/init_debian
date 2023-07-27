#!/bin/bash
# Check if the user is in the sudo group
E_NOTROOT=87 # Non-root exit error.

## check if is sudoer
echo "============== [S] [ 1-1 / 6 ] Prepare =============="
if ! $(sudo -l &> /dev/null); then
    echo "  sudo permission need to run this script"
    echo "  $(whoami) user should be in a sudo user group"
    echo ""
    echo "  su -"
    echo "  adduser $(whoami) sudo"
    echo ""
    echo "  [FAIL] excute upper command and re-excute script "
    exit $E_NOTROOT
fi
echo "============== [S] [ 1-1 / 6 ] Prepare =============="

echo -e "GET http://google.com HTTP/1.0\n\n" | nc google.com 80 > /dev/null 2>&1

if [ "$1" == "" ]; then
    if [ $? -eq 0 ]; then
        echo -e "  Start \033[33mNormal\033[m install..."
        sleep 2
        ./2_apt.sh
        ./3_flatpak.sh
        ./4_firewall.sh
        ./5_custom.sh $(whoami)
        ./6_remove_trash.sh
        echo "  All done!! Need to Reboot"
    else
        echo "  [FAIL] Please check Internet connection"
    fi
fi

if [ "$1" == "minimal" ]; then
    if [ $? -eq 0 ]; then
        echo -e "  Start \033[32mMinimal\033[m install..."
        sleep 2
        ./2_apt.sh
        ./3_flatpak.sh
        ./94_firewall.sh
        ./95_custom.sh $(whoami)
        ./6_remove_trash.sh
        echo "  All done!! Need to Reboot"
    else
        echo "  [FAIL] Please check Internet connection"
    fi
fi