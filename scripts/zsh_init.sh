#!/bin/zsh
cp .zfunctions ~/
cp .zshrc ~/
cp .gitconfig ~/
cp .gitignore_global ~/
cp -Rapv .config/nvim/* ~/.config/nvim
sudo cp sudoers.d/* /etc/sudoers.d/
mkdir -p ~/Workspace
cp -R .ssh ~/
cp -R .aws ~/
chmod 700 ~/.ssh
chmod 600 ~/.ssh/config ~/.ssh/config_linux
