#!/bin/zsh
pnpm setup
source ~/.zshrc
pnpm install -g newman nodemon intelephense
mkcert -install
