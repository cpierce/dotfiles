#!/bin/zsh
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac
# tree-sitter-cli is required by nvim-treesitter (main branch) to compile
# parsers; the Homebrew `tree-sitter` formula ships only the C library.
pnpm add -g newman nodemon intelephense tree-sitter-cli
mkcert -install
curl -fsSL https://claude.ai/install.sh | bash
