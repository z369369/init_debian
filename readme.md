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

installation path : /home/lwh/git/init_debian

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
git clone https://github.com/ppp821203/init_debian.git ~/git/init_debian
chmod +x ~/git/init_debian/*.sh
cd ~/git/init_debian
./00_all.sh
```