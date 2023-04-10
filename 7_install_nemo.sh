#!/bin/bash
git clone https://github.com/Elagoht/nemo-copy-path ~/.local/share/nemo/actions
sudo apt install xclip

rm -rf ~/.local/share/nemo/scripts
ln -s ~/.local/share/nautilus/scripts ~/.local/share/nemo/scripts