## Relate Document
- [Upper - Readme.md](readme.md)

## Prepare

## Install 

### Install distrobox
```
sudo apt install distrobox

dbox list

dbox create arch -i quay.io/toolbx-images/archlinux-toolbox

dbox enter arch

sudo pacman -S base-devel git
```

## Install Package (dbox enter 후)

### yay
```
cd ~/git
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
```

### common
```
sudo pacman -S neofetch
```

### pamac-manager
```
sudo pacman -S pamac-aur
```

## Export
### .desktop to host 
```
distrobox-export --app pamac-manager
```