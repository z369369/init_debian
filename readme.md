---
date: 2023-03-14
status: Complete 
alias: Ubuntu
tags: Software
---

# Ubuntu 22.04 Gnome custom installation

install path : /home/lwh/git/linux_init

user name : lwh

## command

```
sudo apt -y install git
mkdir ~/git
cd ~/git
git clone https://github.com/ppp821203/linux_init.git
chmod -R 777 ~/git
cd linux_init
./0_all.sh
```