#!/bin/bash

echo "============== [S] 2.Telemetry Off =============="

# Disable the services
sudo systemctl stop apport.service
sudo systemctl disable apport.service
sudo systemctl stop whoopsie.service
sudo systemctl disable whoopsie.service

echo "Disabling telemetry"
sudo apt remove ubuntu-report popularity-contest apport whoopsie -y

# Prevent telemetry from being reinstalled 
printf "Package: ubuntu-report\nPin: release a=*\nPin-Priority: -10" >> no-ubuntu-report.pref 
sudo mv no-ubuntu-report.pref /etc/apt/preferences.d/
sudo chown root:root /etc/apt/preferences.d/no-ubuntu-report.pref

printf "Package: whoopsie\nPin: release a=*\nPin-Priority: -10" >> no-whoopsie.pref 
sudo mv no-whoopsie.pref /etc/apt/preferences.d/
sudo chown root:root /etc/apt/preferences.d/no-whoopsie.pref

printf "Package: apport\nPin: release a=*\nPin-Priority: -10" >> no-apport.pref 
sudo mv no-apport.pref /etc/apt/preferences.d/
sudo chown root:root /etc/apt/preferences.d/no-apport.pref
echo "Completed"

echo "============== [E] 2.Telemetry Off =============="


echo "============== [S] 2.Telemetry Off =============="
if ! grep -q "ubuntu" /etc/hosts; then
  # If the word "popcon" does not exist, add it to the end of the file
  echo "127.0.0.1 www.metrics.ubuntu.com" | sudo tee -a /etc/hosts > /dev/null
  echo "127.0.0.1 metrics.ubuntu.com" | sudo tee -a /etc/hosts > /dev/null
  echo "127.0.0.1 www.popcon.ubuntu.com" | sudo tee -a /etc/hosts > /dev/null
  echo "127.0.0.1 popcon.ubuntu.com" | sudo tee -a /etc/hosts > /dev/null
fi
echo "============== [E] 2.Telemetry Off =============="