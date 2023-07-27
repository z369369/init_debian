#!/bin/bash
echo "============== [S] [ 4 / 6 ] Firewall =============="

sudo ufw default deny incoming
sudo ufw default deny outgoing

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
sudo ufw allow 1000:1100/udp
sudo ufw allow out 1000:1100/udp
sudo ufw allow 5000:5002/udp
sudo ufw allow out 5000:5002/udp

#game streaming port
sudo ufw allow 9663
sudo ufw allow out 9663

#ping, traceroute enable
sudo ufw allow out to any port 33434:33524 proto udp

RDP
ufw allow 3389
ufw allow out 3389

vnc
ufw allow 5900
ufw allow out 5900

#torrent port
sudo ufw allow 51413
sudo ufw allow out 51413

sudo ufw allow out on virbr0

sudo ufw reload

echo "============== [E] [ 4 / 6 ] Firewall =============="
