#!/bin/bash
setup-alphine 

apk update 

apk add flatpak
flatpak remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak install -y flathub com.valvesoftware.Steam
flatpak install -y flathub com.github.tchx84.Flatseal
flatpak install -y flathub page.codeberg.libre_menu_editor.LibreMenuEditor

apk add sudo git neofetch htop gedit 

setup-xorg-base

apk add xfce4 xfce4-terminal xfce4-screensaver lightdm-gtk-greeter

yes | cp -rf ./lightdm.conf /etc/lightdm/lightdm.conf

adduser lwh

rc-service dbus start
rc-update add dbus

rc-update add lightdm
rc-service lightdm start
