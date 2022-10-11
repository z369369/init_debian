#!/bin/bash
echo "============== [S] Remove - previous apps =============="

sudo dnf remove -y \
    thunderbird gnome-games \
    rhythmbox totem deja-dup \
    simple-scan cheese hexchat \
    aisleriot gnome-{mahjongg,mines,sudoku} sgt-*

echo "============== [E] Remove - previous apps =============="


echo "============== [S] Install - dnf =============="

sudo dnf install -y $(cat pkglist_dnf)

echo "============== [E] Install - dnf =============="