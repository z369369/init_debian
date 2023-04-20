#!/bin/bash
sudo ufw default deny incoming
sudo ufw default deny outgoing

#local network possible
sudo ufw allow from 192.168.31.0/24
sudo ufw allow out from 192.168.31.0/24

#http
sudo ufw allow 80
sudo ufw allow out 80

#SSL
sudo ufw allow 443
sudo ufw allow out 443

#common ssl port
sudo ufw allow 8443
sudo ufw allow out 8443

#game streaming port
sudo ufw allow 9663
sudo ufw allow out 9663

#syncthing
sudo ufw allow 21027
sudo ufw allow out 21027

#microsoft game pass
sudo ufw allow 1030:1099/udp
sudo ufw allow out 1030:1099/udp

sudo ufw reload
