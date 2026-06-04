#!/bin/zsh
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac
# tree-sitter-cli is required by nvim-treesitter (main branch) to compile
# parsers; the Homebrew `tree-sitter` formula ships only the C library.
# @zed-industries/claude-agent-acp is the ACP bridge CodeCompanion talks to
# (provides the `claude-agent-acp` binary; formerly @zed-industries/claude-code-acp).
pnpm add -g newman nodemon intelephense tree-sitter-cli @zed-industries/claude-agent-acp
mkcert -install
curl -fsSL https://claude.ai/install.sh | bash
