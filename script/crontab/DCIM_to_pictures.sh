#!/bin/bash
rsync -a --exclude-from /home/lwh/phone/DCIM --exclude .stf* /home/lwh/phone/DCIM/ /home/lwh/Pictures/
#rm -rf ~/phone/DCIM/*
#sleep 20s

find /home/lwh/phone/DCIM -type f -exec rm -f {} \;
