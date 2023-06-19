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

1. Need to add sudo user

```
su -

adduser lwh sudo
```
2. Excute script

```
su - lwh

sudo apt -y install git
git clone https://github.com/ppp821203/linux_init.git ~/git/linux_init
chmod +x ~/git/linux_init/*.sh
cd ~/git/linux_init
./00_all.sh
```