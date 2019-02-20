if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

# You may uncomment the following lines if you want `ls' to be colorized:
export LS_OPTIONS='--color=auto'
eval "`dircolors`"
alias ls='ls $LS_OPTIONS'
alias ll='ls $LS_OPTIONS -l'
alias l='ls $LS_OPTIONS -lA'

# Some more alias to avoid making mistakes:
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# sync history kerina perintah si i ketik bas terminal
export HISTCONTROL=ignoredups:erasedups
shopt -s histappend
export PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND$'\n'}history -a; history -c; history -r"

# bedaken konek via SSH ras lokal
if [ -n "$SSH_CLIENT" ]; then
    PS1="\[\e[1;30m\][\[\e[1;33m\]\u@\H\[\e[1;30m\]\[\e[0;32m\]\[\e[1;30m\]] \[\e[1;37m\]\w\[\e[0;37m\] \n\$ "
else
    PS1="\[\e[1;30m\][\[\e[1;31m\]\u@\H\[\e[1;30m\]\[\e[0;32m\]\[\e[1;30m\]] \[\e[1;37m\]\w\[\e[0;37m\] \n\$ "
fi

# SINAMPATI
alias passna='pwgen -s -B -y -a 20 1'
alias passna2='pwgen -s -B -n -c -a 20 1'
alias ww='cd /var/www/html'
alias wget='wget --content-disposition'
alias gitdiff='git diff --name-only'
alias wget0='wget -O /dev/null'
alias xclip='xclip -selection c'
alias gitcommit='git commit -S -m'
alias lanengen='cat ~/lanengen.md | xclip'
