#!/bin/bash
rsync -a --exclude-from ~/phone/DCIM --exclude .stf* ~/phone/DCIM/ ~/Pictures/
#rm -rf ~/phone/DCIM/*
find ~/phone/DCIM -type f -exec rm -f {} \;

