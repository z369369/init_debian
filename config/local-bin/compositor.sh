#!/usr/bin/env bash

# xfwm4 컴포지터 활성화 상태 체크
CHANNEL="xfwm4"
PROPERTY="/general/use_compositing"

CURRENT_STATE=$(xfconf-query -c "$CHANNEL" -p "$PROPERTY" 2>/dev/null)

if [ "$CURRENT_STATE" = "true" ]; then
    # 1. 설정값 변경 (컴포지팅 비활성화)
    xfconf-query -c "$CHANNEL" -p "$PROPERTY" -s false
    
    # 2. 확실한 적용을 위해 xfwm4 컴포지팅 엔진 즉시 갱신
    xfwm4 --replace &
    
    notify-send -u low -i controller "Game Mode" "Game Mode ENABLED\n(Compositor OFF)"
else
    # 1. 설정값 변경 (컴포지팅 활성화)
    xfconf-query -c "$CHANNEL" -p "$PROPERTY" -s true
    
    # 2. xfwm4 재실행하여 컴포지터 재로드
    xfwm4 --replace &
    
    notify-send -u low -i video-display "Game Mode Off" "Game Mode DISABLED\n(Compositor ON)"
fi