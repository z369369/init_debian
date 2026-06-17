#!/bin/bash

# 1. UFW 활성화 상태 확인 (active / inactive)
STATUS=$(cat ~/.key | sudo -S ufw status | grep "Status" | awk '{print $2}')

# 2. 기본 Incoming 정책 확인 (verbose 옵션에서 추출)
# 정상적이라면 'deny' 문자열을 반환합니다.
INCOMING_POLICY=$(cat ~/.key | sudo -S ufw status verbose | grep "Default:" | sed -E 's/.*Default: ([a-z]+) \(incoming\).*/\1/')

# 3. 조건 검사: 활성화 상태이고 동시에 incoming 정책이 deny인 경우
if [ "$STATUS" = "active" ] && [ "$INCOMING_POLICY" = "deny" ]; then
    echo "UFW : In X (Perfect!)"
elif [ "$STATUS" = "active" ]; then
    # UFW는 켜져 있으나 Incoming 정책이 deny가 아닌 경우 (예: allow 등)
    echo "UFW : In O (Weak..)"
else
    # UFW 자체가 꺼져 있는 경우
    echo "UFW : OFF"
fi