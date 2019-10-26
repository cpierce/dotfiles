# Paths
export PATH="$PATH:$HOME/npm/bin:/usr/local/opt/node@10/bin"
export NODE_PATH="$NODE_PATH:$HOME/npm/lib/node_modules:$HOME/.composer/vendor/bin"

# Skip .DS_Store and .localized on tab tab
autoload -Uz compinit
compinit
zstyle ':completion:*:*:*:*:*files' ignored-patterns '.DS_Store|.localized'

# Prompt
PROMPT='(#%F{060}%!%f) %F{111}%n%f@%F{111}%m%f:%F{104}%~%f%# '

# Grep Colors
export GREP_OPTIONS='--color=auto'
export GREP_COLOR='38;5;208'

# Set Default Editor
export EDITOR="/usr/local/bin/vim"

# History Details
export HISTCONTROL=ignoreboth
export HISTSIZE=1000
export HISTFILESIZE=2000

# ls colors and settings
export CLICOLOR=1
export LSCOLORS=AxfxBxDxcxegedabagacad
alias ls='ls -GFh'

# Aliases
alias pwgen='pwgen -cnyB 16 1 | tr -d "\n" | pbcopy; echo -n "Password copied to clipboard: "; pbpaste; echo'
alias myip='curl -s ifconfig.co | tr -d "\n" | pbcopy; echo -n "IP Address is: "; pbpaste; echo'
alias pubkey='cat ~/.ssh/id_rsa.pub | tr -d "\n" | pbcopy; echo "~/.ssh/id_rsa.pub copied to clipboard."'
alias sudo='sudo '

# Load the fowarding agent if it is not (Only keys not certs)
/usr/bin/ssh-add -k >/dev/null 2>&1

# Load custom functions
source ~/.zfunctions
