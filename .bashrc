# Colors
  black='\e[0;30m'
    red='\e[0;31m'
  green='\e[0;32m'
 yellow='\e[0;33m'
   blue='\e[0;34m'
 purple='\e[0;35m'
   cyan='\e[0;36m'
  white='\e[0;37m'

# Bold
 bblack='\e[1;30m'
   bred='\e[1;31m'
 bgreen='\e[1;32m'
byellow='\e[1;33m'
  bblue='\e[1;34m'
bpurple='\e[1;35m'
  bcyan='\e[1;36m'
 bwhite='\e[1;37m'

# High Intensity
 iblack='\e[0;90m'
   ired='\e[0;91m'
 igreen='\e[0;92m'
iyellow='\e[0;93m'
  iblue='\e[0;94m'
ipurple='\e[0;95m'
  icyan='\e[0;96m'
 iwhite='\e[0;97m'

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

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

PS1='${debian_chroot:+($debian_chroot)}'${bblack}'\u@\h:\w'${iwhite}'\n\$ '

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
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

alias ll='ls -alhF --group-directories-first'
alias bashrc="emacs ~/.bashrc &"

alias findf='find . -type f'

alias gg='git grep'

cd ~/dev
