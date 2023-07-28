## Prepare

### gedit ~/.bashrc
```
alias dbox="distrobox"
```

## Install 

### Install distrobox
```
sudo apt install distrobox

dbox list

dbox create ubuntu -i ubuntu:22.04

dbox enter ubuntu
```

## Install Package (dbox enter 후)

### common 
```
sudo apt install git neofetch apt-transport-https software-properties-common
```

### abricotine
```
sudo dpkg -i /home/lwh/Downloads/zip/abricotine_1.1.4_amd64.deb

sudo apt install libnss3 libasound2

sudo apt --fix-broken install
```

### vs code
```
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo install -o root -g root -m 644 microsoft.gpg /usr/share/keyrings/microsoft-archive-keyring.gpg
sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/usr/share/keyrings/microsoft-archive-keyring.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'

sudo apt-get update
sudo apt-get install code 
```

### gnome startup
```
sudo apt install gnome-startup-applications
```

### simplescreenrecorder
```
sudo apt install simplescreenrecorder
```

## Export
### .desktop to host 
```
distrobox-export --app abricotine
distrobox-export --app code
distrobox-export --app gnome-session-properties
distrobox-export --app simplescreenrecord
```