#!/bin/bash
echo "============== [S] 3.Install - apt =============="

sudo apt-get update
sudo apt -y autoremove
sudo apt-get autoclean
sudo apt-get -y upgrade

sudo apt-get install --only-upgrade `sudo apt-get upgrade | awk 'BEGIN{flag=0} /The following packages have been kept back:/ { flag=1} /^ /{if (flag) print}'`
sudo apt-get install --only-upgrade `sudo apt-get upgrade | awk 'BEGIN{flag=0} /다음 패키지를 과거 버전으로 유지합니다:/ { flag=1} /^ /{if (flag) print}'`

sudo apt install -y $(grep -vE "^\s*#" install.list | sed -e 's/#.*//'  | tr "\n" " " | cut -d '*' -f 1)

sudo apt -y autoremove

echo "============== [E] 3.Install - apt =============="

