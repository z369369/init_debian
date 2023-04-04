---
date: 2023-03-14
status: Complete 
alias: Ubuntu
tags: Software
---

# Ubuntu 22.04 Gnome custom installation

1. Clean up Ubuntu unnecessary services.
2. Install Flatpak and APT packages for me.

install path : /home/lwh/git/linux_init
user name : lwh

## command

```
sudo apt -y install git
git clone https://github.com/ppp821203/linux_init.git ~/git/linux_init
chmod +x ~/git/linux_init/*.sh
cd ~/git/linux_init
./0_all.sh
```