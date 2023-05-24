#!/bin/bash
while true; do

	# Run the command.
	cd /home/lwh/git 
	/usr/bin/env /home/lwh/git/py/.venv/bin/python3 /home/lwh/git/linux_init/script/py/crontab_calendar.py 

	# Sleep for 40 seconds.
	sleep 40

done

