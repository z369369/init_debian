[fwBasic]
status = enabled
incoming = deny
outgoing = allow
routed = disabled

[Rule0]
ufw_rule = 3389 ALLOW IN Anywhere
description = remote
command = /usr/sbin/ufw allow in from any to any port 3389
policy = allow
direction = in
protocol = 
from_ip = 
from_port = 
to_ip = 
to_port = 3389
iface = 
routed = 
logging = 

[Rule1]
ufw_rule = 1714:1764/tcp ALLOW IN Anywhere
description = kde
command = /usr/sbin/ufw allow in proto tcp from any to any port 1714:1764
policy = allow
direction = in
protocol = tcp
from_ip = 
from_port = 
to_ip = 
to_port = 1714:1764
iface = 
routed = 
logging = 

[Rule2]
ufw_rule = 1714:1764/udp ALLOW IN Anywhere
description = kde
command = /usr/sbin/ufw allow in proto udp from any to any port 1714:1764
policy = allow
direction = in
protocol = udp
from_ip = 
from_port = 
to_ip = 
to_port = 1714:1764
iface = 
routed = 
logging = 

[Rule3]
ufw_rule = 3389 (v6) ALLOW IN Anywhere (v6)
description = remote
command = /usr/sbin/ufw allow in from any to any port 3389
policy = allow
direction = in
protocol = 
from_ip = 
from_port = 
to_ip = 
to_port = 3389
iface = 
routed = 
logging = 

[Rule4]
ufw_rule = 1714:1764/tcp (v6) ALLOW IN Anywhere (v6)
description = kde
command = /usr/sbin/ufw allow in proto tcp from any to any port 1714:1764
policy = allow
direction = in
protocol = tcp
from_ip = 
from_port = 
to_ip = 
to_port = 1714:1764
iface = 
routed = 
logging = 

[Rule5]
ufw_rule = 1714:1764/udp (v6) ALLOW IN Anywhere (v6)
description = kde
command = /usr/sbin/ufw allow in proto udp from any to any port 1714:1764
policy = allow
direction = in
protocol = udp
from_ip = 
from_port = 
to_ip = 
to_port = 1714:1764
iface = 
routed = 
logging = 

