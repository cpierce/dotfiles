export PATH=/usr/local/mysql/bin:$PATH

# 256 Color
function EXT_COLOR () { echo -ne "\[\033[38;5;$1m"; }

# Skip .DS_Store on tab tab
export FIGNORE=$FIGNORE:DS_Store

# Grep Colors
export GREP_OPTIONS='--color=auto'
export GREP_COLOR='38;5;208'

# Set Editor for Default Stuff
export EDITOR="/usr/local/bin/vim"

# NPM Installs Locally
export PATH="$PATH:$HOME/npm/bin"
export NODE_PATH="$NODE_PATH:$HOME/npm/lib/node_modules"

# History Details
export HISTCONTROL=ignoreboth
export HISTSIZE=1000
export HISTFILESIZE=2000

# ls colors and settings
export CLICOLOR=1
export LSCOLORS=AxfxBxDxcxegedabagacad
alias ls='ls -GFh'
alias pwgen="pwgen -cn 16 | tr -d '\n' | cut -c 1-16 | pbcopy ; echo 'Password copied to clipboard.'"


# PS1 Prompt
export PS1="(\[\e[0m\]#\[\e[38;5;60m\]\!\[\e[0m\]) \[\e[38;5;74m\]\u\[\e[0m\]@\[\e[38;5;74m\]\h\[\e[0m\]:\[\e[38;5;147m\]\w\[\e[0;37m\]\$\[\e[0m\] "
