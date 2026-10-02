# ------------------------------------------
# Paths and Config Options
# ------------------------------------------
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH:$HOME/.composer/vendor/bin"
if [ -d /opt/homebrew ]; then
    export PATH="$PATH:/opt/homebrew/opt/node/bin:/opt/homebrew/bin"
fi
export NODE_PATH="$NODE_PATH:$HOME/npm/lib/node_modules"
export NVM_DIR="$HOME/.nvm"
export EDITOR="vim"
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
if [[ "$OSTYPE" == linux* ]]; then
    # macOS sets these in /etc/zshrc; Linux zsh has no default HISTFILE
    HISTFILE="$HOME/.zsh_history"
    HISTSIZE=10000
    SAVEHIST=10000
    setopt SHARE_HISTORY
else
    export HISTSIZE=1000
    export HISTFILESIZE=2000
fi
export CLICOLOR=1
export LSCOLORS=AxfxBxDxcxegedabagacad
export GREP_COLORS="ms=01;31:mc=01;31:sl=01;34:cx=01;34:fn=35:ln=32:bn=32:se=36"
export PWGEN_SPECIAL=\'\"\@\?\^\&\*\(\)\`\:\~\?\;\:\[\]\{\}\.\,\\\/\|
export WORKSPACE="$HOME/Workspace"

# ------------------------------------------
# Key Bindings (Home/End/Delete aren't bound by default on Linux)
# ------------------------------------------
if [[ "$OSTYPE" == linux* ]]; then
    bindkey -e
    [[ -n "${terminfo[khome]}" ]] && bindkey "${terminfo[khome]}" beginning-of-line
    [[ -n "${terminfo[kend]}" ]] && bindkey "${terminfo[kend]}" end-of-line
    [[ -n "${terminfo[kdch1]}" ]] && bindkey "${terminfo[kdch1]}" delete-char
fi

# ------------------------------------------
# Clipboard (pbcopy/pbpaste shims for Wayland/X11)
# ------------------------------------------
# On Wayland, zsh_init.sh installs pbcopy/pbpaste scripts into /usr/local/bin;
# the functions below only cover machines without them.
if ! command -v pbcopy > /dev/null; then
    if command -v wl-copy > /dev/null; then
        pbcopy() { wl-copy "$@"; }
        pbpaste() { wl-paste --no-newline "$@"; }
    elif command -v xclip > /dev/null; then
        pbcopy() { xclip -selection clipboard "$@"; }
        pbpaste() { xclip -selection clipboard -o "$@"; }
    fi
fi

# ------------------------------------------
# Node Version Manager (NVM)
# ------------------------------------------
# Homebrew (macOS), pacman (Arch), then a manual install in $NVM_DIR.
if [ -s "/opt/homebrew/opt/nvm/nvm.sh" ]; then
    \. "/opt/homebrew/opt/nvm/nvm.sh"
    [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
elif [ -s "/usr/share/nvm/init-nvm.sh" ]; then
    \. "/usr/share/nvm/init-nvm.sh"
elif [ -s "$NVM_DIR/nvm.sh" ]; then
    \. "$NVM_DIR/nvm.sh"
fi

# ------------------------------------------
# Load Modules and Completion
# ------------------------------------------
[ -d "$HOME/.docker/completions" ] && fpath=($HOME/.docker/completions $fpath)
autoload -Uz compinit && compinit

# ------------------------------------------
# External Tools
# ------------------------------------------
if command -v direnv > /dev/null; then
    eval "$(direnv hook zsh)"
fi
if command -v zoxide > /dev/null; then
    eval "$(zoxide init zsh)"   # z <fragment> jumps to a frecent directory
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
if command -v eza > /dev/null; then
    alias ls='eza -aF --group-directories-first --icons=auto'
else
    alias ls='ls -AGFh --color=auto'
fi
if command -v bat > /dev/null; then
    alias cat='bat --paging=never'
fi
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
    if [ -f ~/.fzf.zsh ]; then
        source ~/.fzf.zsh       # written by Homebrew's fzf install script
    else
        source <(fzf --zsh)
    fi
fi
if command -v atuin > /dev/null; then
    eval "$(atuin init zsh)"    # must come after fzf to own Ctrl+R
fi
[ -f ~/.config/op/plugins.sh ] && source ~/.config/op/plugins.sh
[ -f ~/.op/plugins.sh ] && source ~/.op/plugins.sh
[ -f ~/.zfunctions ] && source ~/.zfunctions

# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"

# pnpm
if [[ "$OSTYPE" == darwin* ]]; then
    export PNPM_HOME="$HOME/Library/pnpm"
else
    export PNPM_HOME="$HOME/.local/share/pnpm"
fi
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac
# pnpm end

# ------------------------------------------
# tmux: auto-attach on SSH logins
# ------------------------------------------
# Interactive SSH session, not already inside tmux, tmux available:
# attach to the "ssh" session or create it. Detaching or a dropped
# connection leaves the session running for next time.
if [[ -n "$SSH_CONNECTION" && -z "$TMUX" && -o interactive ]] && command -v tmux > /dev/null; then
    exec tmux new-session -A -s ssh
fi

# ------------------------------------------
# Zsh Plugins (syntax highlighting must load last)
# ------------------------------------------
# Homebrew (macOS) and pacman (Arch) install these under different prefixes.
for plugin in zsh-autosuggestions zsh-syntax-highlighting; do
    for dir in /opt/homebrew/share /usr/share/zsh/plugins; do
        if [ -f "$dir/$plugin/$plugin.zsh" ]; then
            source "$dir/$plugin/$plugin.zsh"
            break
        fi
    done
done
unset plugin dir
