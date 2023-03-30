#!/bin/bash

echo "============== [S] 2.Telemetry Off =============="

# Disable the services
sudo systemctl stop apport.service
sudo systemctl disable apport.service
sudo systemctl stop whoopsie.service
sudo systemctl disable whoopsie.service

echo "Disabling telemetry"
sudo apt remove ubuntu-report whoopsie apport -y

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


echo "============== [S] 2.Remove - ubuntu ESM =============="
sudo mkdir /etc/apt/apt.conf.d/off
sudo mv /etc/apt/apt.conf.d/20apt-esm-hook.conf /etc/apt/apt.conf.d/off
echo "============== [S] 2.Remove - ubuntu ESM =============="