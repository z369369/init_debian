---
date: 2023-03-14
status: Complete 
alias: Ubuntu
tags: Software
---

# Debian 12 Gnome 43 custom installation

1. Clean up Default unnecessary apps and services.
2. Install Flatpak and APT packages for me.

## User Information

installation path : /home/lwh/git/linux_init

user name : lwh

## Command

```
sudo apt -y install git
git clone https://github.com/ppp821203/linux_init.git ~/git/linux_init
chmod +x ~/git/linux_init/*.sh
cd ~/git/linux_init
./0_all.sh
```