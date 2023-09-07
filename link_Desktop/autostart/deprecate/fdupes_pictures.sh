#!/bin/bash
rsync -a --exclude-from ~/phone/DCIM --exclude .stf* ~/phone/DCIM/ ~/Pictures/
#rm -rf ~/phone/DCIM/*
#sleep 20s

#find ~/phone/DCIM -type f -exec rm -f {} \;
fdupes -idN -o time ~/Pictures/ ~/phone/DCIM/

fdupes -idN -o time ~/phone/000_Personal/Attachment/ ~/Pictures/

#fdupes는 옵션 order by time asc, i는 reverse
#-i와 -o time 함께 쓰면 최신 것만 남기겠다(time desc)
