#!/bin/sh
SERVICE='gnome-terminal'

if ps ax | grep -v grep | grep $SERVICE > /dev/null
then
  wmctrl -s 4
else
  $SERVICE
fi
