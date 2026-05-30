#!/bin/bash

# Run the command and store the output in a variable
output=$(cat ~/.key | sudo -S ufw status verbose | grep 'allow (outgoing)')

# Check if the output contains the match string
if [[ $output == *"allow (outgoing)"* ]]; then
  # If the match string is found, print the current date
  cat ~/.key | sudo -S ufw default deny outgoing > /dev/null
  cat ~/.key | sudo -S ufw default deny incoming > /dev/null
  notify-send 'Deny outgoing' '보안이 강화 🛡️ 되었습니다'
  #echo "Match found! 외부 나가는 중  The date is $(date +"%Y-%m-%d")"
else
  # If the match string is not found, print the current time
  cat ~/.key | sudo -S ufw default allow outgoing > /dev/null
  cat ~/.key | sudo -S ufw default allow incoming > /dev/null
  notify-send 'Allow outgoing' '보안이 약화 🤪 되었습니다'
  #echo "No match found. 외부 못나가는 중  The time is $(date +"%H:%M:%S")"
fi


