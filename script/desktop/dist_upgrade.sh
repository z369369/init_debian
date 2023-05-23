#!/bin/bash
echo "This script base : /home/lwh/script/desktop/dist_upgrade.sh"
echo "Warning!!! - Ubuntu will be upgrade next distribution"

# Get the user's input
read -p 'Continue? [ y or n ] : ' param1

# Check if the user pressed y
if [[ $param1 = y ]]; then
	cat /home/lwh/.key | sudo -S sudo apt update && sudo apt -y upgrade 
	#cat /home/lwh/.key | sudo -S sudo apt-get install --only-upgrade `sudo apt-get upgrade | awk 'BEGIN{flag=0} /The following packages have been kept back:/ { flag=1} /^ /{if (flag) print}'`
	#cat /home/lwh/.key | sudo -S sudo apt-get install --only-upgrade `sudo apt-get upgrade | awk 'BEGIN{flag=0} /다음 패키지를 과거 버전으로 유지합니다:/ { flag=1} /^ /{if (flag) print}'`

	cat /home/lwh/.key | sudo -S sudo apt update && sudo apt -y upgrade 
	#cat /home/lwh/.key | sudo -S sudo apt-get install --only-upgrade `sudo apt-get upgrade | awk 'BEGIN{flag=0} /The following packages have been kept back:/ { flag=1} /^ /{if (flag) print}'`
	#cat /home/lwh/.key | sudo -S sudo apt-get install --only-upgrade `sudo apt-get upgrade | awk 'BEGIN{flag=0} /다음 패키지를 과거 버전으로 유지합니다:/ { flag=1} /^ /{if (flag) print}'`

	sudo do-release-upgrade -d
fi
