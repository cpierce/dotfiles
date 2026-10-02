#!/bin/zsh
cp .zfunctions ~/
cp .zshrc ~/
cp .gitconfig ~/
mkdir -p ~/.config/ghostty
cp .config/ghostty/config.ghostty ~/.config/ghostty/config.ghostty
mkdir -p ~/.ssh
if [[ "$(uname -s)" == "Darwin" ]]; then
  cp .gitconfig_macos ~/.gitconfig_os
  cp .ssh/config ~/.ssh/config
  # %admin and the Homebrew vim paths only exist on macOS
  sudo cp sudoers.d/* /etc/sudoers.d/
else
  cp .gitconfig_linux ~/.gitconfig_os
  cp .ssh/config_linux ~/.ssh/config
  # Ghostty keybinds assume keyd's Cmd->Ctrl remap, so Linux only
  cp .config/ghostty/config_linux.ghostty ~/.config/ghostty/config_os.ghostty
  # macOS-style `open` (wraps xdg-open)
  install -Dm755 resources/linux/open ~/.local/bin/open
  # macOS-style pbcopy/pbpaste for Wayland
  if command -v wl-copy > /dev/null; then
    sudo install -m 755 resources/linux/pbcopy resources/linux/pbpaste /usr/local/bin/
  fi
fi
cp .gitignore_global ~/
mkdir -p ~/.config/nvim
cp -Rapv .config/nvim/* ~/.config/nvim/
cp .config/starship.toml ~/.config/starship.toml
mkdir -p ~/.config/atuin
cp .config/atuin/config.toml ~/.config/atuin/config.toml
mkdir -p ~/Workspace
cp -R .aws ~/
chmod 700 ~/.ssh
chmod 600 ~/.ssh/config
