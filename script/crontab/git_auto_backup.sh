#!/bin/bash
cd ~/git/linux_init

git add .

message=`date`

git commit -m "$message"

git push origin
