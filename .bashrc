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
#[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

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

    #alias grep='grep --color=auto'
    #alias fgrep='fgrep --color=auto'
    #alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
#alias ll='ls -l'
#alias la='ls -A'
#alias l='ls -CF'

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

ripfzf() {
    # 검색어 인자 확인 (1글자 이상)
    if [[ -z "$1" || ${#1} -lt 1 ]]; then
        echo "검색어(1글자 이상)를 입력하세요."
        return 1
    fi

    local query="$1"

    # rg 옵션 설명
    # --hidden 제외(숨김파일 무시)
    # --glob '!.git/*' : .git 무시 (속도 개선)
    # --glob '!*' : 숨김파일 제외를 위해 이미 --hidden 을 쓰지 않음
    # -n : 줄번호
    # -H : 파일명 표시
    # --color always : fzf preview용
    rg --no-hidden \
       --glob '!.git/*' \
       -n -H --color=always "$query" |
    fzf --layout=reverse --ansi \
        --preview "batcat --style=plain --color=always {1} --line-range {2}: {2}" \
        --delimiter : \
        --preview-window=right:60% \
        --bind "enter:become(micro {1} +{2})"
}


alias aupdate='sudo apt update'
alias aupgrade='sudo apt upgrade'
alias bat='batcat --style=plain'
alias boottime='systemd-analyze'
alias c='clear'
alias cat='batcat --style=plain'
alias df='pydf'
alias du='ncdu -x'
alias free='free -m'
alias frepair='flatpak repair --user'
alias fupdate='flatpak update --user --assumeyes'
alias jctl='journalctl'
alias ls='exa'
alias myip='curl ifconfig.me;echo ""'
alias nano='micro'
alias nf='neofetch'
alias pw="apg -a 1 -m 16 -x 16 -n 10 -M NCLS"
alias r="source ~/.bashrc"
alias sysctl='systemctl'
alias syslog='sudo cat /var/log/syslog | less'
alias clog='sudo tail -f /var/log/syslog'
alias tcreate='sudo timeshift --create --comments'
alias tlist='sudo timeshift --list'
alias top='htop'
alias tremove='sudo timeshift --delete'
alias trestore='sudo timeshift --restore'
alias vi='micro'
alias z='zoxide query'

export FZF_DEFAULT_COMMAND="fdfind --hidden --follow --exclude '.git'"
export FZF_DEFAULT_OPTS="--preview 'batcat --style=plain --color=always {}' 
--preview-window right:60%
--bind 'ctrl-/:toggle-preview'
--bind 'ctrl-e:execute(code {})'
--bind 'ctrl-g:execute(gedit {})'
--bind 'enter:become(micro {1} +{2})'
"
export EDITOR='micro'
export VISUAL='micro'


bind -x '"\C-f": fzf --layout=reverse'
bind -x '"\C-r": ripfzf " "'

/home/lwh/.local/bin/check_debian_eol_curl.sh
