## Relate Document
- [Upper - Readme.md](readme.md)

## Prepare

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

### gnome startup
```
sudo apt install gnome-startup-applications
```

## Export
### .desktop to host 
```
distrobox-export --app gnome-session-properties
```