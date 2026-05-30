#!/bin/bash

# --- VM 설정 변수 ---

# 첫 번째 인자 ($1)가 비어 있는지 확인
if [ -z "$1" ]; then
    echo "오류: VM 이름 또는 명령을 지정해야 합니다."
    echo ""
    echo "사용법:"
    echo "  $0 <VM_NAME>                  # 기존 VM 실행 (디스크 부팅)"
    echo "예시:"
    echo "  $0 MyDebianServer"
    exit 1
fi

VM_NAME="$1"
VM_NAME_TEMP="${VM_NAME%.*}"
INSTALL_MODE=false
CPU_CORES=4
RAM_GB=8
# ISO 파일 경로 (VM 이름과 동일한 이름을 가진 .iso 파일로 가정)
ISO_PATH="${VM_NAME_TEMP}.iso" 
NEW_DISK_PATH="${VM_NAME_TEMP}.qcow2"

# --- 디스크 이미지 준비 ---
if [ ! -f "$NEW_DISK_PATH" ]; then
    echo "새 디스크 이미지 $NEW_DISK_PATH 를 50GB 크기로 생성 중..."
    # 디스크 파일이 없으면 50GB 크기로 생성
    qemu-img create -f qcow2 "$NEW_DISK_PATH" 50G
    echo "생성 완료."
	INSTALL_MODE=true
	sleep 1
fi

# 설치 모드일 경우 ISO 파일 존재 여부 확인
if $INSTALL_MODE; then
    if [ ! -f "$ISO_PATH" ]; then
        echo "오류: 설치 모드가 요청되었으나, ISO 파일이 경로에 없습니다: $ISO_PATH"
        exit 1
    fi
fi

# --- QEMU 명령어 구성 ---
QEMU_CMD="cat /home/lwh/.key | sudo -S qemu-system-x86_64 \
    -name \"$VM_NAME_TEMP\" \
    -enable-kvm \
    -m ${RAM_GB}G \
    -smp ${CPU_CORES} \
	-netdev user,id=vnet0 \
	-device e1000,netdev=vnet0 \
	-usb \
	-device qemu-xhci \
	-device usb-host,vendorid=0x04e8,productid=0x331e \
	-device usb-host,vendorid=0x0781,productid=0x5567 \
	-device usb-host,vendorid=0x0416,productid=0xb030 \
    -hda \"$NEW_DISK_PATH\" \
    -vga virtio \
    -display sdl \
    -cpu host "

# 설치 모드(--install)일 경우 -cdrom 및 -boot d 옵션 추가
if $INSTALL_MODE; then
    QEMU_CMD="$QEMU_CMD -cdrom \"$ISO_PATH\" -boot d"
    echo "VM 이름: $VM_NAME_TEMP (설치 부팅 - CD-ROM(d) 우선 부팅)"
else
    # 일반 부팅일 경우 디스크(c)로 명시적 부팅
    QEMU_CMD="$QEMU_CMD -boot c"
    echo "VM 이름: $VM_NAME_TEMP (일반 부팅 - 디스크(c) 우선 부팅)"
fi

echo "--- QEMU 실행 ---"

echo $QEMU_CMD
# QEMU 실행
eval $QEMU_CMD

echo "실행 완료."
