#!/bin/zsh
pnpm setup
source ~/.zshrc
pnpm install -g newman nodemon intelephense
mkcert -install
curl -fsSL https://claude.ai/install.sh | bash

