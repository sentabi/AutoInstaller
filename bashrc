if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

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

# simpan history kU syslog
PROMPT_COMMAND='{ msg=$(history 1 | { read x y; echo $y; });logger "[euid=$(whoami)]":$(who am i):[`pwd`]"$msg"; }'

# PS1 man koneksi arah git
if [ -n "$SSH_CLIENT" ]; then
    PS1="\[\e[1;30m\][\[\e[1;33m\]\u@\H\[\e[1;30m\]\[\e[0;32m\]\[\e[1;30m\]] \[\e[1;37m\]\w\[\e[0;37m\] \n\$ "
fi

# ALIAS

# PASSWORD GENERATOR
alias passna='pwgen -s -B -y -a 20 1'
alias passna2='pwgen -s -B -n -c -a 20 1'

alias wget0='wget -O /dev/null'
alias wget='wget --content-disposition'
alias ww='cd /var/www/html'
alias xclip='xclip -selection c'
alias youtube-dl='youtube-dl -f best'
alias hostkuip='for a in $(ls -d */); do host ${a%%/}; done'
alias lanengen='cat ~/lanengen.md | xclip'


# GIT
alias gitcommit='git commit -S -m'
alias gituntracked='git ls-files . --exclude-standard --others'
alias gitdiff='git diff --name-only'

# LARAVEL
alias laravelinstall='composer create-project --prefer-dist laravel/laravel $1'
alias bersihlaravel='php artisan route:clear;php artisan view:clear;php artisan config:clear;php artisan cache:clear;'


# Download git git-prompt.sh
# wget https://raw.github.com/git/git/master/contrib/completion/git-prompt.sh -O ~/.git-prompt.sh
source ~/.git-prompt.sh
PS1='\n\[\033[0;32m\]\u@\h \[\033[1;33m\]\w \[\033[0m\]$(__git_ps1 "(%s)")\n> '
