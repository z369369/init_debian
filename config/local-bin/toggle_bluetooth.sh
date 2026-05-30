#!/bin/bash
#sudo modprobe -r btusb # 모듈 제거

# Turn off Bluetooth
cat /home/lwh/.key | sudo -S bluetoothctl power off

# Sleep for 10 seconds
sleep 1

# Turn on Bluetooth
cat /home/lwh/.key | sudo -S bluetoothctl power on

bluetoothctl disconnect 74:45:CE:6A:C3:FF
sleep 1

bluetoothctl trust 74:45:CE:6A:C3:FF
bluetoothctl connect 74:45:CE:6A:C3:FF

#bluetoothctl trust MAC-address
#bluetoothctl disconnect MAC-address
#bluetoothctl connect MAC-address

#sudo modprobe btusb # 모듈 다시 로드
