#!/bin/zsh
cp .zfunctions ~/
cp .zshrc ~/
cp .gitconfig ~/
cp .gitignore_global ~/
cp -Rapv .config/nvim/* ~/.config/
sudo cp sudoers.d/* /etc/sudoers.d/
mkdir -p ~/Workspace
cp -R .ssh ~/
cp -R .aws ~/
sudo chmod 700 ~/.ssh
