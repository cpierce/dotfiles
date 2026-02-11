# ------------------------------------------
# Paths and Config Options
# ------------------------------------------
export PATH="$PATH:/opt/homebrew/opt/node/bin:$HOME/.composer/vendor/bin:/opt/homebrew/bin"
export NODE_PATH="$NODE_PATH:$HOME/npm/lib/node_modules"
export NVM_DIR="$HOME/.nvm"
export EDITOR="vim"
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
export HISTSIZE=1000
export HISTFILESIZE=2000
export CLICOLOR=1
export LSCOLORS=AxfxBxDxcxegedabagacad
export GREP_COLORS="ms=01;31:mc=01;31:sl=01;34:cx=01;34:fn=35:ln=32:bn=32:se=36"
export PWGEN_SPECIAL=\'\"\@\?\^\&\*\(\)\`\:\~\?\;\:\[\]\{\}\.\,\\\/\|
export WORKSPACE="$HOME/Workspace"

# ------------------------------------------
# Node Version Manager (NVM)
# ------------------------------------------
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"

# ------------------------------------------
# Load Modules and Completion
# ------------------------------------------
autoload -Uz compinit && compinit

# ------------------------------------------
# External Tools
# ------------------------------------------
if command -v direnv > /dev/null; then
    eval "$(direnv hook zsh)"
fi

# Skip .DS_Store and .localized on tab tab
zstyle ':completion:*:*:*:*:*files' ignored-patterns '.DS_Store' '.localized'

# ------------------------------------------
# Prompt (Starship)
# ------------------------------------------
if command -v starship > /dev/null; then
    eval "$(starship init zsh)"
fi

# ------------------------------------------
# Aliases
# ------------------------------------------
alias ls='ls -AGFh --color=auto'
alias tree='tree -a -C --dirsfirst -L 2 --noreport'
alias pwgen='pwgen -cnyB 32 1 -r $PWGEN_SPECIAL | tr -d "\n" | pbcopy; echo -n "Password copied to clipboard: "; pbpaste; echo'
alias myip='curl -s ifconfig.co | tr -d "\n" | pbcopy; echo -n "IP Address is: "; pbpaste; echo'
alias pubkey='op item get "SSH Key - Primary" --fields "public key" | pbcopy; echo "ED25519 pub key copied to clipboard."'
alias ping='ping -c 10'
alias sudo='sudo '
alias grep='grep --color=auto'
alias phpstan='phpstan --memory-limit=512M'
alias reload='source ~/.zshrc'
alias tf='terraform'

# ------------------------------------------
# Load External Configurations
# ------------------------------------------
if command -v fzf > /dev/null; then
    [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
fi
[ -f ~/.config/op/plugins.sh ] && source ~/.config/op/plugins.sh
[ -f ~/.zfunctions ] && source ~/.zfunctions

# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=($HOME/.docker/completions $fpath)
# End of Docker CLI completions
