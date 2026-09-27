#!/bin/bash
# @DESC: vault 실행 (볼트 - 이미지 최적화, 이미지 이동, 백업)
# @TAGS: vault, optimizer, image, backup
# @USAGE: vault_main.sh
# @STATUS: 사용중

sleep 5
/home/lwh/Desktop/bin/resize_image.sh
sleep 5
/home/lwh/Desktop/bin/vault_image.sh
sleep 5
/home/lwh/Desktop/bin/vault_backup.sh