#!/bin/bash
rsync -a --exclude-from ~/phone/DCIM --exclude .stf* ~/phone/DCIM/ ~/Pictures/
#rm -rf ~/phone/DCIM/*
#sleep 20s

#find ~/phone/DCIM -type f -exec rm -f {} \;
fdupes -rdN ~/Pictures/ ~/phone/DCIM/

fdupes -rdN ~/phone/000_Personal/Attachment/ ~/Pictures/

#fdupes는 앞에 파라미터는 남기고, 뒤에 파라미터 항목은 지운다
