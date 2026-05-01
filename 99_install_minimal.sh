sudo apt install --no-install-recommends 
    xserver-xorg-core 
    xserver-xorg-video-amdgpu 
    xserver-xorg-input-libinput 
    xinit 
    x11-xserver-utils 
    amd64-microcode 
    firmware-amd-graphics

sudo apt install --no-install-recommends xfce4-session xfce4-panel xfwm4 xfce4-settings xfce4-terminal xfce4-appfinder xfce4-screenshooter 

sudo apt install --no-install-recommends 
    pipewire-audio 
    wireplumber 
    pipewire-pulse 
    pipewire-alsa 
    pavucontrol bluez pipewire-audio-client-libraries 
    xfce4-pulseaudio-plugin 

systemctl --user --now enable pipewire pipewire-pulse wireplumber

sudo apt install --no-install-recommends 
    fcitx5 
    fcitx5-hangul 
    fcitx5-config-qt 
    fcitx5-frontend-gtk2 fcitx5-frontend-gtk3 fcitx5-frontend-qt5


sudo apt install --no-install-recommends 
    fonts-noto-cjk 
    fonts-nanum 
    fonts-nanum-coding


sudo apt install --no-install-recommends firefox-esr firefox-esr-l10n-ko


sudo apt install --no-install-recommends 
    network-manager 
    network-manager-gnome 
    wpasupplicant 
    wireless-tools firmware-iwlwifi


sudo apt install --no-install-recommends 
    thunar 
    thunar-volman 
    xfce4-terminal


sudo apt install --no-install-recommends gvfs


sudo apt install --no-install-recommends 
    cups 
    cups-filters 
    printer-driver-splix 
    ghostscript


# 'wonho' 대신 본인의 사용자 계정명을 입력하세요.
sudo usermod -aG lpadmin $(whoami)



sudo apt install --no-install-recommends 
    qemu-system-x86 
    qemu-utils 
    libvirt-daemon-system 
    libvirt-clients 
    bridge-utils 
    virtinst


sudo apt install --no-install-recommends 
    engrampa 
    unzip zip 
    p7zip-full 
    unrar-free 
    thunar-archive-plugin


sudo apt install --no-install-recommends evince evince-common


sudo apt install --no-install-recommends 
    viewnior
    tumbler 
    tumbler-plugins-extra 
    libgsf-1-118 
    libpoppler-glib8
