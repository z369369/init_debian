#!/bin/bash

cat ~/.key | sudo -S systemctl restart bluetooth.service
