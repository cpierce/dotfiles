#!/bin/zsh
WIN_USER="cpier"

sudo apt install ansible nmap php-cli pwgen zsh starship

# Install the folders for Ubuntu
mkdir -p /mnt/c/Users/$WIN_USER/Workspace
ln -s /mnt/c/Users/$WIN_USER/Workspace ~/Workspace
ln -s /mnt/c/Users/$WIN_USER/Documents ~/Documents
ln -s /mnt/c/Users/$WIN_USER/Desktop ~/Desktop
ln -s /mnt/c/Users/$WIN_USER/Downloads ~/Downloads

# Bash Scripts
cp .zfunctions ~/
cp .zshrc ~/
cp .gitconfig ~/
cp .gitignore_global ~/
mkdir -p ~/.config/nvim
cp -Rap .config/nvim/* ~/.config/nvim/
cp .config/starship.toml ~/.config/starship.toml
cp -R .aws ~/
cp -R .ssh/config_linux ~/.ssh/config
chmod 700 ~/.ssh
chmod 600 ~/.ssh/config
