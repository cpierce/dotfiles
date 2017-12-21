#!/bin/sh
cp .bash_functions ~/
cp .bash_profile ~/
cp .gitconfig ~/
cp .gitexcludes ~/
cp .vimrc ~/
sudo cp sudoers.d/* /etc/sudoers.d/
mkdir -p ~/Workspace
cp -R .ssh ~/
chmod 700 ~/.ssh
chown 600 ~/.ssh/id_rsa*

