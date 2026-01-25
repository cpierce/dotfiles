#!/bin/zsh
if [ -x "/opt/homebrew/bin/brew" ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x "/usr/local/bin/brew" ]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi
pnpm setup
source ~/.zshrc
pnpm install -g newman nodemon intelephense
mkcert -install
