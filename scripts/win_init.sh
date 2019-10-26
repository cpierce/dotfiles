#!/bin/sh
sudo apt install ansible nmap php-cli pwgen

# Install the folders for Ubuntu
mkdir /mnt/c/Users/cpier/Workspace/
ln -s /mnt/c/Users/cpier/Workspace ~/Workspace
ln -s /mnt/c/Users/cpier/Documents ~/Documents
ln -s /mnt/c/Users/cpier/Desktop ~/Desktop
ln -s /mnt/c/Users/cpier/Downloads ~/Downloads

# Bash Scripts
cp .zfunctions ~/
cp .zshrc ~/
cp .gitconfig ~/
cp .gitexcludes ~/
cp .vimrc ~/
sudo cp sudoers.d/* /etc/sudoers.d/
mkdir -p ~/Workspace
cp -R .ssh/config_linux ~/.ssh/config
cp -R .ssh/id_rsa* ~/.ssh/
chmod 700 ~/.ssh
chown 600 ~/.ssh/id_rsa*
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
