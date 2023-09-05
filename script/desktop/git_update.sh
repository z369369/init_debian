#!/bin/bash
folders=(
	zzz_ani-cli 
	zzz_dra-cla 
	zzz_jerry 
	zzz_lobster
	zzz_lightnovel-crawler
	zzz_epub-translator
	zzz_nautilus-scripts
)

RED='\033[1;33m'
GREEN='\033[1;32m'
NC='\033[0m' # No Color

# Loop through the folders
for folder in "${folders[@]}"
do
	printf "${RED}GIT refresh${NC} : ${GREEN}~/git/$folder${NC}\n"
	cd ~/git/$folder
	git reset --hard HEAD
	git pull
	echo ""
done

cp -f ~/git/zzz_ani-cli/ani-cli ~/.local/bin/ani-cli
cp -f ~/git/zzz_dra-cla/dra-cla ~/.local/bin/dra-cla
cp -f ~/git/zzz_jerry/jerry.sh ~/.local/bin/jerry
cp -f ~/git/zzz_lobster/lobster.sh ~/.local/bin/lobster

cp -rf ~/git/init_debian/copy_local_share/* ~/.local/share/