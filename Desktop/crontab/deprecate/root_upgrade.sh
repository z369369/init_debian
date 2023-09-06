#!/bin/bash

cat /home/lwh/.key | sudo -S sudo apt update && sudo apt-get -y install --only-upgrade firefox code
#cat /home/lwh/.key | sudo -S sudo apt update && sudo apt -y upgrade 
#cat /home/lwh/.key | sudo -S sudo apt-get install --only-upgrade `sudo apt-get upgrade | awk 'BEGIN{flag=0} /The following packages have been kept back:/ { flag=1} /^ /{if (flag) print}'`
#cat /home/lwh/.key | sudo -S sudo apt-get install --only-upgrade `sudo apt-get upgrade | awk 'BEGIN{flag=0} /다음 패키지를 과거 버전으로 유지합니다:/ { flag=1} /^ /{if (flag) print}'`
