#!/bin/bash

# Check if the "download" directory exists
if [ -d "/home/lwh/Downloads" ]; then
  
  # Get the current time
  now=$(date +%s)

  # Get the access time of the "download" directory
  access_time=$(stat -c %Y /home/lwh/Downloads)

  # Calculate the difference between the current time and the access time
  difference=$((now - access_time))

  # If the difference is greater than 10 hours, run the "difference" command with the echo command
  if [ $difference -gt 36000 ]; then
    /home/lwh/script/desktop/organize.sh
  fi

fi

