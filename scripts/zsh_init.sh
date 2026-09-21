#!/bin/zsh
cp .zfunctions ~/
cp .zshrc ~/
cp .gitconfig ~/
mkdir -p ~/.config/ghostty
cp .config/ghostty/config.ghostty ~/.config/ghostty/config.ghostty
if [[ "$(uname -s)" == "Darwin" ]]; then
  cp .gitconfig_macos ~/.gitconfig_os
else
  cp .gitconfig_linux ~/.gitconfig_os
  # Ghostty keybinds assume keyd's Cmd->Ctrl remap, so Linux only
  cp .config/ghostty/config_linux.ghostty ~/.config/ghostty/config_os.ghostty
fi
cp .gitignore_global ~/
mkdir -p ~/.config/nvim
cp -Rapv .config/nvim/* ~/.config/nvim/
cp .config/starship.toml ~/.config/starship.toml
mkdir -p ~/.config/atuin
cp .config/atuin/config.toml ~/.config/atuin/config.toml
sudo cp sudoers.d/* /etc/sudoers.d/
mkdir -p ~/Workspace
cp -R .ssh ~/
cp -R .aws ~/
chmod 700 ~/.ssh
chmod 600 ~/.ssh/config ~/.ssh/config_linux
