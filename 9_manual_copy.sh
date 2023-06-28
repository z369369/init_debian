#!/bin/bash
echo "============== 9. Restore /etc =============="
sudo rsync -a -I ./etc/ /etc
#sudo chmod 644 /etc/apt/apt.conf.d/99_organize