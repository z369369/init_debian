#!/bin/bash

echo "=== Debian Upgrader ==="
echo "manual : https://www.debian.org/releases/stable/armhf/release-notes/ch-upgrading.en.html"
echo ""
echo "!!! Please close private repo from /etc/apt/source.d !!!"
echo ""	
echo "Need parameter "

echo "1) fix current"
echo "2) [prev_distro] [next_distro] : replace source"
echo "3) mini-upgrade"
echo "4) full-upgrade"

if [ "$1" = "1" ]; then
	echo "=== (1/4) sudo apt update ==="
	sudo apt update
	
	echo "=== (1/4) sudo apt upgrade ==="
	sudo apt upgrade 
fi

if [ "$1" = "2" ]; then
	set -f
	echo "=== (2/4) replace source.list $2 to $3 ==="
	
	sudo cp -v /etc/apt/sources.list /etc/apt/sources.list.$2
	
	if ! [ -n "$2" ]
	then
		echo "Use parameter with [prev_distro] [next_distro]"
		return
	fi
	
	echo "sudo sed -i 's/$2/$3/g' /etc/apt/sources.list"
	sh -c "sudo sed -i 's/$2/$3/g' /etc/apt/sources.list"
	
	echo " "
	echo "Result : "
	sudo cat /etc/apt/sources.list
	echo "Replace Complete!!"
fi

if [ "$1" = "3" ]; then
	echo "=== (3/4) sudo apt update ==="
	sudo apt update
	
	echo "=== (3/4) sudo apt upgrade --without-new-pkgs ==="
	sudo apt upgrade --without-new-pkgs
fi

if [ "$1" = "4" ]; then
	echo "=== (4/4) sudo apt full-upgrade ==="
	sudo apt full-upgrade
fi
