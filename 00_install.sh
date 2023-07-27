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

if [ $? -eq 0 ]; then
    echo "Online"
else
    echo "Offline"
    exit
fi

read -p "Install mode? (Normal / Minimal) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Nn]$ ]]; then
    echo -e "  Start \033[33mNormal\033[m install..."
    ./02_apt.sh
    ./03_flatpak.sh
    ./04_firewall.sh
    ./05_custom.sh $(whoami)
    ./06_remove_trash.sh
fi 

if [[ $REPLY =~ ^[Mm]$ ]]; then
    echo -e "  Start \033[32mMinimal\033[m install..."
    ./02_apt.sh
    ./03_flatpak.sh
    ./14_firewall.sh
    ./15_custom.sh $(whoami)
    ./06_remove_trash.sh
fi
echo "  All done!! Need to Reboot"