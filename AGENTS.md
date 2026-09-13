# AGENTS.md

This file provides guidance to AI coding agents (Claude Code, etc.) when working with code in this repository.

## Overview

macOS-focused dotfiles repo. Config files are stored at the repo root mirroring their home directory paths. The `scripts/` directory contains bootstrap installers. Files are installed by copying them to `~/` (see `scripts/zsh_init.sh`), not via symlinks.

## Bootstrap

```sh
./scripts/init.sh          # runs all scripts below in order
./scripts/zsh_init.sh      # copies dotfiles to ~/ and sets up ~/.config/nvim
./scripts/claude_init.sh   # copies claude/ to ~/.claude (Claude Code user config)
./scripts/brew_init.sh     # installs Homebrew and packages
./scripts/fzf_init.sh      # installs fzf key bindings
./scripts/mac_init.sh      # applies macOS defaults via `defaults write`
./scripts/fonts_init.sh    # installs fonts
./scripts/composer_init.sh # PHP composer global packages
./scripts/post_install.sh  # pnpm setup, mkcert, misc tools
```

## Key Architecture

- **Shell**: Zsh with Starship prompt, direnv, nvm, fzf, 1Password CLI plugin integration. Custom functions live in `.zfunctions` (sourced by `.zshrc`).
- **Neovim**: Lazy.nvim plugin manager. Entry point is `.config/nvim/init.lua` (leader key: `,`). Core modules in `lua/` (`options`, `keymaps`, `autocmds`, `lsp`, `style`). Plugin specs in `lua/plugins/`, separated configs in `lua/config/`. Uses Catppuccin theme, blink.cmp for completion, Mason for LSP servers, and conform.nvim for formatting.
- **Neovim formatting**: StyLua enforces Lua style (`.config/nvim/stylua.toml`): 160 col width, 2-space indent, single quotes, Unix line endings.
- **Claude Code**: User-level config lives in `claude/` (settings, global CLAUDE.md, statusline, hook wrapper, commands, skills) and is copied to `~/.claude` by `claude_init.sh`. It is deliberately not `.claude/` — that path is the repo's own project-scoped config and would make every hook fire twice inside this checkout. Paths in `claude/settings.json` use `$HOME` so the same file works on macOS and Linux; `claude/hooks/cc-status` no-ops when iTerm2 is absent.
- **Git**: Commits are GPG-signed via 1Password SSH agent. Merge tool is VS Code. Default branch is `main`.

## Conventions

- Shell scripts use `#!/bin/zsh` (not bash).
- No symlink manager (stow, etc.) — files are copied directly via `cp` in `zsh_init.sh`.
- AWS CLI commands are wrapped through `op plugin run --` for 1Password credential injection.
