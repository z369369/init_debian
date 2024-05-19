#!/bin/bash
echo "============== [S] [ 4 / 6 ] Firewall =============="

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

sudo ufw allow 8080
sudo ufw allow out 8080

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

#http
sudo ufw allow 22
sudo ufw allow out 22

sudo ufw allow 3306
sudo ufw allow out 3306

#microsoft game pass
sudo ufw allow 1000:1100/udp
sudo ufw allow out 1000:1100/udp
sudo ufw allow 5000:5002/udp
sudo ufw allow out 5000:5002/udp

#game streaming port
sudo ufw allow 9663
sudo ufw allow out 9663

#steam port
sudo ufw allow 27000:27100/udp
sudo ufw allow out 27000:27100/udp

sudo ufw allow 27000:27100/tcp
sudo ufw allow out 27000:27100/tcp

sudo ufw allow 3470:4400/udp
sudo ufw allow out 3470:4400/udp

#syncthing
sudo ufw allow 21027
sudo ufw allow out to 192.168.31.0/24 port 21027

sudo ufw allow 22000
sudo ufw allow out to 192.168.31.0/24 port 22000

#ping, traceroute enable
sudo ufw allow out to any port 33434:33524 proto udp

#RDP
sudo ufw allow 3389
sudo ufw allow out 3389

#vnc
# sudo ufw allow 5900
# sudo ufw allow out 5900

# ssh
sudo ufw allow 37622
sudo ufw allow out 37622

#torrent port
sudo ufw allow 51413
sudo ufw allow out 51413

#moonlight
sudo ufw allow 47984:48010/tcp
sudo ufw allow out 47984:48010/tcp
sudo ufw allow 47984:48010/udp
sudo ufw allow out 47984:48010/udp


sudo ufw allow out on virbr0

sudo ufw reload

echo "============== [E] [ 4 / 6 ] Firewall =============="
