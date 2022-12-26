# Paths
export PATH="$PATH:/opt/homebrew/opt/node@18/bin"
export NODE_PATH="$NODE_PATH:$HOME/npm/lib/node_modules:$HOME/.composer/vendor/bin"

export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

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

# Prompt
PROMPT='%K{060} #%! %k %F{111}%n%f@%F{111}%m%f:%F{104}%~%f%# '
RPROMPT=\$vcs_info_msg_0_
zstyle ':vcs_info:git:*' formats '%K{060} ᚠ %b %k'

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

export PWGEN_SPECIAL=\'\"\@\?\^\&\*\(\)\`\:\~\?\;\:\[\]\{\}\.\,\\\/\|

# Aliases
alias pwgen='pwgen -cnyB 16 1 -r $PWGEN_SPECIAL | tr -d "\n" | pbcopy; echo -n "Password copied to clipboard: "; pbpaste; echo'
alias myip='curl -s ifconfig.co | tr -d "\n" | pbcopy; echo -n "IP Address is: "; pbpaste; echo'
alias pubkey='cat $HOME/.ssh/id_ed25519.pub | pbcopy; echo "ED25519 pub key copied to clipboard."'
alias ping='ping -c 10'
alias sudo='sudo '
alias aws='op run --env-file=$HOME/.config/op/aws-env -- aws'

# Load the fowarding agent if it is not (Only keys not certs)
/usr/bin/ssh-add -k >/dev/null 2>&1

# Load custom functions
source ~/.zfunctions
