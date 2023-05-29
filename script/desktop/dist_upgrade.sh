#!/bin/bash
echo "UPGRADE New Ubuntu"
read -p "Do you want to proceed? (y/n) " yn

case $yn in 
	[yY] ) echo ok, we will proceed;
		sudo apt -y update && sudo apt -y upgrade && sudo apt -y autoremove && sudo apt -y autoclean
		cat /home/lwh/.key | sudo -S sudo apt-get install --only-upgrade `sudo apt-get upgrade | awk 'BEGIN{flag=0} /The following packages have been kept back:/ { flag=1} /^ /{if (flag) print}'`
		cat /home/lwh/.key | sudo -S sudo apt-get install --only-upgrade `sudo apt-get upgrade | awk 'BEGIN{flag=0} /다음 패키지를 과거 버전으로 유지합니다:/ { flag=1} /^ /{if (flag) print}'`

		sudo apt -y update && sudo apt -y upgrade && sudo apt -y autoremove && sudo apt -y autoclean
		cat /home/lwh/.key | sudo -S sudo apt-get install --only-upgrade `sudo apt-get upgrade | awk 'BEGIN{flag=0} /The following packages have been kept back:/ { flag=1} /^ /{if (flag) print}'`
		cat /home/lwh/.key | sudo -S sudo apt-get install --only-upgrade `sudo apt-get upgrade | awk 'BEGIN{flag=0} /다음 패키지를 과거 버전으로 유지합니다:/ { flag=1} /^ /{if (flag) print}'`
		sudo do-release-upgrade -d
		echo "ok, we will proceed"
		;;
	
	[nN] ) echo exiting...;
		;;
	* ) echo invalid response
		;;
esac
