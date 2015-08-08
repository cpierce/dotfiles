export PATH=/usr/local/mysql/bin:$PATH

# Grep Colors
export GREP_OPTIONS='--color=auto'
export GREP_COLOR='1;30;40'

# NPM Installs Locally
export PATH="$PATH:$HOME/npm/bin"
export NODE_PATH="$NODE_PATH:$HOME/npm/lib/node_modules"

# History Details
export HISTCONTROL=ignoreboth
export HISTSIZE=1000
export HISTFILESIZE=2000

# ls colors and settings
export CLICOLOR=1
export LSCOLORS=exfxBxDxcxegedabagacad
alias ls='ls -GFh'

# PS1 Prompt
export PS1="(\[\e[0m\]#\[\e[0;34m\]\!\[\e[0m\]) \[\e[0;36m\]\u\[\e[0;37m\]@\[\e[0;36m\]\h\[\e[0;37m\]:\[\e[0;34m\]\w\[\e[0;37m\]\$\[\e[0m\] "
