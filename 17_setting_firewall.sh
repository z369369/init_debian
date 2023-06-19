#!/bin/bash
su -

ufw default deny incoming
ufw default deny outgoing

#gsconnect
ufw allow 1714:1764/tcp
ufw allow out 1714:1764/tcp

ufw allow 1714:1764/udp
ufw allow out 1714:1764/udp

#http
ufw allow 80
ufw allow out 80

#SSL
ufw allow 443
ufw allow out 443

#common ssl port
ufw allow 8443
ufw allow out 8443

#DNS / APT install port
ufw allow 53
ufw allow out 53

#DHCP port
ufw allow 67
ufw allow out 67

#network timer
ufw allow 123
ufw allow out 123

#microsoft game pass
ufw allow 1000:1100/udp
ufw allow out 1000:1100/udp
ufw allow 5000:5002/udp
ufw allow out 5000:5002/udp

#game streaming port
ufw allow 9663
ufw allow out 9663

#syncthing
ufw allow 21027
ufw allow out to 192.168.31.0/24 port 21027

ufw allow 22000
ufw allow out to 192.168.31.0/24 port 22000

#ping, traceroute enable
ufw allow out to any port 33434:33524 proto udp

#RDP
# ufw allow 3389
# ufw allow out 3389

#vnc
# ufw allow 5900
# ufw allow out 5900

ufw allow out on virbr0

ufw reload