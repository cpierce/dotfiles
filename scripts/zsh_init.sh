#!/bin/zsh
cp .zfunctions ~/
cp .zshrc ~/
cp .gitconfig ~/
cp .gitignore_global ~/
mkdir -p ~/.config/nvim
cp -Rapv .config/nvim/* ~/.config/nvim/
cp .config/starship.toml ~/.config/starship.toml
sudo cp sudoers.d/* /etc/sudoers.d/
mkdir -p ~/Workspace
cp -R .ssh ~/
cp -R .aws ~/
chmod 700 ~/.ssh
chmod 600 ~/.ssh/config ~/.ssh/config_linux
