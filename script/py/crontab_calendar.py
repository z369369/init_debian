# -*- coding: utf-8 -*-

from __future__ import print_function

import os
import sys
import re
import time
from datetime import date, datetime,timedelta
import datetime as dt
import pymysql
import httpx
import random
import json
import comdr
import config as c
import logging
import redis

# import singleton
# me = singleton.SingleInstance()


class MyCalendar():

    def __init__(self):
        # comdr.check_process()
        try:
            self.service = comdr.get_service('lwh', 'calendar')

        except Exception as e:
            logging.error(f"Error {e}")
            sys.exit(1)
 
    def set_onething(self):
        i_num = 0
        i_num_max = 5
        with open("/home/lwh/script/py/crontab_calendar.txt", "r") as f:
            i_num = int(f.read())
            f.close()
        
        i_num = i_num + 1

        if i_num >= i_num_max:
            i_num = 0
                
        # Call the Calendar API
        now = dt.datetime.utcnow().isoformat() + 'Z'  # 'Z' indicates UTC time
        events_result = self.service.events().list(calendarId='primary', timeMin=now,
                                              maxResults=i_num_max, singleEvents=True,
                                              orderBy='startTime').execute()
        events = events_result.get('items', [])

        if not events:
            return

        # Prints the start and name of the next 10 events
        s1 = ''
        s2 = ''
        a1 = []
        for event in events:
            start = event['start'].get('dateTime', event['start'].get('date'))
            # print(start, event['summary'])
            s1 = start[5:16]
            s1 = s1.replace("-",".").replace("T"," ")
            a1.append(s1 + ' ' + event['summary'][0:10])

        s1 = a1[i_num]
        # print(s1)
        
        cmd = 'gsettings set org.gnome.shell.extensions.one-thing thing-value "' + s1 + '"'
        os.system(cmd)
        
        with open("/home/lwh/script/py/crontab_calendar.txt", "w") as f:
            f.write(str(i_num))
            f.close()            
        
        return
       
if __name__ == '__main__':
    comdr.setup_logging(__file__, c.LOG_PRINT)
    mcal = MyCalendar()
    # mcal.set_stock()
    mcal.set_onething()
    #-----------------------------------------
    # mcal.push_to_google_calendar()
    