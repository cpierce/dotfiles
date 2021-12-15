#!/bin/sh
cp .zfunctions ~/
cp .zshrc ~/
cp .gitconfig ~/
cp .gitexcludes ~/
cp .vimrc ~/
sudo cp sudoers.d/* /etc/sudoers.d/
mkdir -p ~/Workspace
cp -R .ssh ~/
sudo chown cpierce ~/.ssh/id_*
sudo chmod 700 ~/.ssh
sudo chown 600 ~/.ssh/id_*
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
