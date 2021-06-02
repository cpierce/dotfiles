#!/bin/sh
source ~/.zshrc
/opt/homebrew/opt/node@12/bin/npm install -g newman
/opt/homebrew/bin/ansible-vault decrypt ~/.ssh/id_rsa
