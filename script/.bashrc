# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alhF'
alias la='ls -A'
#alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

STCOLOR1="\e[32m"
ENDCOLOR="\e[0m"

cgrep() {
	set -f
	echo "------------------ ${1} ----------------------"
	
	if [[ ${1} == "*" ]]
	then
		echo "Usage : full extension *.* "
		echo "EXIT!!"
		return
	fi	
	
	if ! [ -n "${2}" ]
	then
		echo "Usage : cgrep [*.ext] [keyword]"
		echo "EXIT!!"
		return
	fi
	
	#grep -snr --include="$1" --exclude-dir={.config,.var,timeshift,.Trash*,media} "$2" 
	grep -snr --include="${1}" --exclude-dir={.config,.var,.cache,timeshift,.Trash*,media} -oE ".{0,10}$2.{0,40}"
	
}

cdistro(){
	echo "=== Debian Upgrader ==="
	echo "manual : https://www.debian.org/releases/stable/armhf/release-notes/ch-upgrading.en.html"
	echo ""
	echo "cdistro1 : fix current"
	echo "cdistro2 [prev_distro] [next_distro] : replace source"
	echo "cdistro3 : mini-upgrade"
	echo "cdistro4 : full-upgrade"
}

cdistro1() {
	echo "=== (1/4) sudo apt update ==="
	sudo apt update
	
	echo "=== (1/4) sudo apt upgrade ==="
	sudo apt upgrade 
}

cdistro2() {
	set -f
	echo "=== (2/4) replace source.list $1 to $2 ==="
	
	sudo cp -v /etc/apt/sources.list /etc/apt/sources.list.$1
	
	if ! [ -n "$2" ]
	then
		echo "Usage : cdistro2 [prev_distro] [next_distro]"
		return
	fi
	
	echo "sudo sed -i 's/$1/$2/g' /etc/apt/sources.list"
	sh -c "sudo sed -i 's/$1/$2/g' /etc/apt/sources.list"
	
	echo " "
	echo "Result : "
	sudo cat /etc/apt/sources.list
	echo "Replace Complete!!"
}

cdistro3() {
	echo "=== (3/4) sudo apt update ==="
	sudo apt update
	
	echo "=== (3/4) sudo apt upgrade --without-new-pkgs ==="
	sudo apt upgrade --without-new-pkgs
}

cdistro4() {
	echo "=== (4/4) sudo apt full-upgrade ==="
	sudo apt full-upgrade
}

cfind() {
	set -f
	echo '-----------------------------------------'
	find . -iname "${1}" -not -path "./media/*" -not -path "./run/*" -not -path "./home/timeshift/*"  -not -path "./home/.Trash*/*"
}

fback() {
	flatpak update --commit=$2 $1
}

ime() {
	ibus exit
	ibus-daemon -d
}

ping() {
	if [[ $1 =~ ^[a-z0-9]+\.[a-z]{2,6}$ ]]; then
	  host $1
	else
	  nslookup $1
	fi
}

myip() {
	nmcli device show wlp1s0
	v1=$(curl -s http://ipecho.net/plain)
	echo -e "My IP Address : ${STCOLOR1}${v1}${ENDCOLOR}"
}

vin(){
    python3 -m venv .venv
    source .venv/bin/activate
}

bootfix(){
	sudo rm /var/lib/dpkg/lock
	sudo rm /var/lib/dpkg/lock-frontend
	sudo rm /var/lib/apt/lists/lock
	sudo rm /var/cache/apt/archives/lock
	sudo dpkg --configure -a
	sudo apt update
	sudo apt clean
	sudo apt update --fix-missing
	sudo apt install -f
	sudo apt update
	sudo apt dist-upgrade
}

chat(){
	source /home/lwh/git/terminal_chat/.venv/bin/activate
	cd /home/lwh/git/terminal_chat
	python3 app.py
}

alias vout="deactivate"

#boot repair
alias bootlog="sudo dmesg -H"
alias ufwlog="sudo dmesg -w"
alias dlog="sudo dmesg -f daemon"
alias syslog='journalctl -f'
#alias syslog='cat ~/.key | sudo -S tail -f /var/log/syslog'

#package
alias finstall="flatpak install"
alias fremove="flatpak remove"
alias fupdate="flatpak update"

alias flist="flatpak list"
alias finfo="flatpak remote-info --log flathub"
alias frun="flatpak run"
alias frepair="flatpak repair --user"

alias ainstall="sudo apt install"
alias aremove="sudo apt remove"
#alias aupdate="sudo apt -y update && sudo apt -y upgrade && sudo apt -y autoremove && sudo apt -y autoclean"
alias ahistory="cat /var/log/apt/history.log"
alias wifi="nmtui"


#system command
alias ..="cd .."
alias c="clear"
alias du="ncdu"
alias df="pydf"
alias nf="neofetch"
alias free="free -h"
alias psg="ps aux | grep -v grep | grep -i -e VSZ -e"
alias top="htop"
alias webify="mogrify -resize 690\> *.png"
alias weather="curl -s v2.wttr.in"
alias reboot="systemctl reboot"
alias shutdown="systemctl poweroff"

#connect other
#alias gcp='~/script/gcp.sh'

#network
alias listenp='sudo watch ss -tunp'
alias listen='sudo watch ss -tunl'
alias telnet='nc -zvw3'
alias update-grub3='sudo grub-mkconfig -o /boot/grub/grub.cfg'

#timeshift
alias tlist='sudo timeshift --list'
alias tcreate='sudo timeshift --create'
alias trestore='sudo timeshift --restore'
alias tdelete='sudo timeshift --delete'

export HISTCONTROL=ignoredups
export EDITOR='vi'
