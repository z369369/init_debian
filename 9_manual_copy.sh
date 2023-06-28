#!/bin/bash
echo "============== 9. Restore /etc =============="
sudo rsync -a -I ./etc/ /etc
#sudo chmod 644 /etc/apt/apt.conf.d/99_organize

echo "============== 9. Restore syncthing =============="
#syncthing
sudo systemctl enable syncthing@lwh.service
#sudo gedit /lib/systemd/system/syncthing@.service
#echo "add --allow-newer-config"
#like under
#ExecStart=/usr/bin/syncthing serve --allow-newer-config --no-browser --no-restart --logflags=0