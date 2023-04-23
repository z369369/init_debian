#!/bin/bash
sudo ufw default deny incoming
sudo ufw default deny outgoing

#gsconnect
sudo ufw allow 1714:1764/tcp
sudo ufw allow out 1714:1764/tcp

sudo ufw allow 1714:1764/udp
sudo ufw allow out 1714:1764/udp

#http
sudo ufw allow 80
sudo ufw allow out 80

#SSL
sudo ufw allow 443
sudo ufw allow out 443

#common ssl port
sudo ufw allow 8443
sudo ufw allow out 8443

#DNS / APT install port
sudo ufw allow 53
sudo ufw allow out 53

#DHCP port
sudo ufw allow 67
sudo ufw allow out 67

#network timer
sudo ufw allow 123
sudo ufw allow out 123

#microsoft game pass
sudo ufw allow 1030:1099/udp
sudo ufw allow out 1030:1099/udp

#multicast dns - game
# sudo ufw allow 5353
# sudo ufw allow out 5353

# #game streaming port
# sudo ufw allow 9663
# sudo ufw allow out 9663

#syncthing
sudo ufw allow 21027
sudo ufw allow out to 192.168.31.0/24 port 21027

sudo ufw allow 22000
sudo ufw allow out to 192.168.31.0/24 port 22000

#RDP
# sudo ufw allow 3389
# sudo ufw allow out 3389

#vnc
# sudo ufw allow 5900
# sudo ufw allow out 5900

sudo ufw allow out on virbr0

sudo ufw reload
