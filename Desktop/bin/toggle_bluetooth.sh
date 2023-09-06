#!/bin/bash

# Turn off Bluetooth
cat /home/lwh/.key | sudo -S bluetoothctl power off

# Sleep for 10 seconds
sleep 5

# Turn on Bluetooth
cat /home/lwh/.key | sudo -S bluetoothctl power on

sleep 3

bluetoothctl connect 74:45:CE:6A:C3:FF
