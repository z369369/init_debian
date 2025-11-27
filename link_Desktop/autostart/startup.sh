#!/bin/bash
#sound
#~/Desktop/autostart/fdupes_pictures.sh
#~/Desktop/autostart/wallpaper.sh
#python3 ~/Desktop/py/autostart_gnome_extension.py
# cat ~/.key | sudo -S systemctl start bluetooth.service

#!/bin/bash


#resize img
/home/lwh/Desktop/bin/img_resize_replace.sh /home/lwh/phone/DCIM/Camera/
/home/lwh/Desktop/bin/move_screenshot.sh

# 인터넷 연결을 확인할 최대 시도 횟수
MAX_ATTEMPTS=50
# 시도 간 대기 시간 (초)
WAIT_TIME=0.5
# 확인을 위해 사용할 신뢰할 수 있는 외부 IP (Google DNS)
TARGET_HOST="8.8.8.8" # Google의 웹페이지를 사용

for (( i=1; i<=$MAX_ATTEMPTS; i++ )); do
	
	if /usr/bin/ping -c 1 -W 5 $TARGET_HOST > /dev/null 2>&1; then
		cat ~/.key | sudo -S ufw default deny outgoing 
		cat ~/.key | sudo -S ufw default deny incoming
		cat ~/.key | sudo -S ufw enable
		#cat ~/.key | sudo usbreset 2563:0526

		wmctrl -s 4
		gnome-terminal
		sleep 1

		wmctrl -s 3
		nautilus &
		sleep 1
		#nohup nautilus ~ 1> /dev/null 2>&1 &

		wmctrl -s 2
		nohup firefox-esr 1> /dev/null 2>&1 &
		sleep 1
		#/usr/bin/flatpak run --branch=stable --arch=x86_64 --command=steam com.valvesoftware.Steam steam://open/games

		#nohup syncthing --allow-newer-config --no-browser 1> /dev/null 2>&1 &
		disown

		#sleep 10
		#sshfs -o password_stdin kmsw@kmsw.mycafe24.com:/kmsw/www /home/lwh/git/kmsw <<< 'Tmzkdl2403!@'
		#sleep 10


		exit 0
	else
		sleep $WAIT_TIME
	fi
done	
