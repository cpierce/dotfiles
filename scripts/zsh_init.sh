#!/bin/sh
cp .zfunctions ~/
cp .zshrc ~/
cp .gitconfig ~/
cp .gitexcludes ~/
cp .vimrc ~/
sudo cp sudoers.d/* /etc/sudoers.d/
mkdir -p ~/Workspace
cp -R .ssh ~/
sudo chown cpierce ~/.ssh/id_ed25519.pub
sudo chmod 700 ~/.ssh
sudo chown 600 ~/.ssh/id_ed25519.pub
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
