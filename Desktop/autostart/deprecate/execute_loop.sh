#!/bin/bash
while true; do

	# Run the command.
	cd ~/git 
	/usr/bin/env ~/git/py/.venv/bin/python3 ~/git/init_debian/Desktop/crontab/crontab_calendar.py 

	# Sleep for 40 seconds.
	sleep 40

done

