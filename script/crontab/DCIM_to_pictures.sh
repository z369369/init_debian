#!/bin/bash
rsync -a --exclude-from /home/$USER/phone/DCIM --exclude .stf* /home/$USER/phone/DCIM/ /home/$USER/Pictures/
#rm -rf ~/phone/DCIM/*
#sleep 20s

find /home/$USER/phone/DCIM -type f -exec rm -f {} \;
