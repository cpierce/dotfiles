#!/bin/zsh
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac
pnpm add -g newman nodemon intelephense
mkcert -install
curl -fsSL https://claude.ai/install.sh | bash
