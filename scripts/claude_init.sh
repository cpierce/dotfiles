#!/bin/zsh
# Installs Claude Code user-level config into ~/.claude.
# Source lives in claude/ rather than .claude/ on purpose: a .claude/ at the repo
# root would also be read as this repo's *project* config, so every hook would
# fire twice whenever Claude Code runs inside the dotfiles checkout.
mkdir -p ~/.claude/hooks ~/.claude/commands ~/.claude/skills
cp claude/settings.json ~/.claude/settings.json
cp claude/CLAUDE.md ~/.claude/CLAUDE.md
cp claude/statusline-command.sh ~/.claude/statusline-command.sh
cp -R claude/hooks/* ~/.claude/hooks/
cp -R claude/commands/* ~/.claude/commands/
cp -Rap claude/skills/* ~/.claude/skills/
chmod +x ~/.claude/statusline-command.sh ~/.claude/hooks/*
