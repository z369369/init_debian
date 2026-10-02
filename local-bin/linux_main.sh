#!/bin/bash
# @DESC: linux main
# @TAGS: linux, startup
# @USAGE: linux_main.sh
# @STATUS: 사용중

sleep 2
/home/lwh/.local/bin/rename_screenshot.sh
sleep 2
/home/lwh/.local/bin/dcim_link.sh
sleep 2
/home/lwh/.local/bin/move_gemini_img.sh