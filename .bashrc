export LANG=en_US.UTF-8
export LC_MESSAGES="C"

# =============================================================================
# If not running interactively, don't do anything
# =============================================================================
# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# =============================================================================
# Git auto complete and prompt settings
# =============================================================================
. /usr/share/git/completion/git-completion.bash
. /usr/share/git/completion/git-prompt.sh

GIT_PS1_SHOWSTASHSTATE=true
GIT_PS1_SHOWDIRTYSTATE=true

# =============================================================================
# Color definitions
# =============================================================================
clear_clr="\e[0m"
bold="\e[1m"
invert="\e[7m"

black="\e[30m"
red="\e[31m"
green="\e[32m"
yellow="\e[33m"
blue="\e[34m"
purple="\e[35m"
cyan="\e[36m"
light_gray="\e[37m"
gray="\e[90m"
light_red="\e[91m"
light_green="\e[92m"
light_yellow="\e[93m"
light_blue="\e[94m"
light_purple="\e[95m"
light_cyan="\e[96m"
white="\e[97m"

# =============================================================================
# History
# =============================================================================
# Don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# For setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# =============================================================================
# Make less more friendly for non-text input files, see lesspipe(1)
# =============================================================================
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# =============================================================================
# PS1
# =============================================================================
PS1=${yellow}'[$?]'${gray}' \u@\h'${gray}'$(__git_ps1 " (%s)")'${gray}' \w'${clear_clr}'\n\$ '

# =============================================================================
# Coloring for ls and grep
# =============================================================================
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls="ls --color=auto"

    alias grep="grep --color=auto"
    alias fgrep="fgrep --color=auto"
    alias egrep="egrep --color=auto"
fi

# =============================================================================
# Enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
# =============================================================================
# if ! shopt -oq posix; then
#   if [ -f /usr/share/bash-completion/bash_completion ]; then
#     . /usr/share/bash-completion/bash_completion
#   elif [ -f /etc/bash_completion ]; then
#     . /etc/bash_completion
#   fi
# fi

# =============================================================================
# Timestamp function
# =============================================================================
function ts()
{
    date +%Y-%m-%d.%H.%M.%S
}

# =============================================================================
# ll alias (must be defined before the cd function below)
# =============================================================================
alias ll="ls -Alhtr --classify --group-directories-first"

# =============================================================================
# cd function
# =============================================================================
function cd_and_ls()
{
    cd $1
    ls
}

# =============================================================================
# Misc aliases
# =============================================================================
alias bashrc="emacs ~/.bashrc &"

alias emacs="emacs -fs"

alias gg="git grep"
alias gs="git fetch --all --prune ; git st"

alias u="cd .."

alias cd="cd_and_ls"

# Go to dev directory
alias dev="cd $HOME/dev"

# Go to Infra Arcana repo
alias ia="cd $HOME/dev/ia"

# Go to loekchipz repo
alias lc="cd $HOME/dev/loekchipz"

# =============================================================================
# Preferred C/C++ compilers
# =============================================================================
export   C=gcc
export CXX=g++

# =============================================================================
# Rust stuff
# =============================================================================
export PATH=/home/martin/dev/rust-install/bin:$PATH

export PATH=/home/martin/.cargo/bin:$PATH

export RUST_SRC_PATH=/home/martin/dev/rust/src

export CARGO_HOME=/home/martin/.cargo

# =============================================================================
# Print timestamps on bash commands
# =============================================================================
# trap 'echo -e "${invert}$(ts)${clear_clr}"' DEBUG
