# Paths and Config Options
export PATH="$PATH:/opt/homebrew/opt/node/bin:$HOME/.composer/vendor/bin"
export NODE_PATH="$NODE_PATH:$HOME/npm/lib/node_modules"
export NVM_DIR="$HOME/.nvm"
export EDITOR="/usr/local/bin/vim"
export HISTCONTROL=ignoreboth
export HISTSIZE=1000
export HISTFILESIZE=2000
export CLICOLOR=1
export LSCOLORS=AxfxBxDxcxegedabagacad
export GREP_COLOR='38;5;208'
export PWGEN_SPECIAL=\'\"\@\?\^\&\*\(\)\`\:\~\?\;\:\[\]\{\}\.\,\\\/\|

# Load LVM
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"

# Load Modules for Zsh
autoload -Uz compinit
compinit
autoload -Uz vcs_info
precmd_vcs_info() { vcs_info }
precmd_functions+=( precmd_vcs_info )
setopt prompt_subst

# direnv enable
eval "$(direnv hook zsh)"

# Skip .DS_Store and .localized on tab tab
zstyle ':completion:*:*:*:*:*files' ignored-patterns '.DS_Store|.localized'

# Prompt Configuration
PROMPT='%K{060} #%! %k %F{111}%n%f@%F{111}%m%f:%F{104}%~%f%# '
RPROMPT=\$vcs_info_msg_0_
zstyle ':vcs_info:git:*' formats '%K{060} ᚠ %b %k'

# Aliases
alias ls='ls -AGFh'
alias pwgen='pwgen -cnyB 16 1 -r $PWGEN_SPECIAL | tr -d "\n" | pbcopy; echo -n "Password copied to clipboard: "; pbpaste; echo'
alias myip='curl -s ifconfig.co | tr -d "\n" | pbcopy; echo -n "IP Address is: "; pbpaste; echo'
alias pubkey='op item get "SSH Key - Primary" --fields "public key" | pbcopy; echo "ED25519 pub key copied to clipboard."'
alias ping='ping -c 10'
alias sudo='sudo '
alias grep='grep --color=auto'

# Load cutom functions, fzf, and op plugins
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
[ -f ~/.config/op/plugins.sh ] && source ~/.config/op/plugins.sh
[ -f ~/.zfunctions ] && source ~/.zfunctions
