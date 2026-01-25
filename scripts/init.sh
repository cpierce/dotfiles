#!/bin/zsh
if [ -x "/opt/homebrew/bin/brew" ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x "/usr/local/bin/brew" ]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi
./scripts/zsh_init.sh
./scripts/brew_init.sh
./scripts/mac_init.sh
./scripts/fonts_init.sh
./scripts/post_install.sh
