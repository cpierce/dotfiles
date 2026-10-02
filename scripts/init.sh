#!/bin/zsh
source ./scripts/zsh_init.sh
source ./scripts/claude_init.sh
# Homebrew, its fzf installer, the composer bootstrap and `defaults write` are
# macOS only. On Arch, install the equivalents with pacman/paru.
if [[ "$(uname -s)" == "Darwin" ]]; then
  source ./scripts/brew_init.sh
  source ./scripts/fzf_init.sh
  source ./scripts/composer_init.sh
  source ./scripts/mac_init.sh
fi
source ./scripts/fonts_init.sh
source ./scripts/post_install.sh
