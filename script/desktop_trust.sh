#!/bin/bash

for i in ~/Desktop/*.desktop; do    gio set "$i" "metadata::trusted" true ; chmod +x "$i";done

notify-send 'Complete' 'Press F5 for refresh Desktop'
