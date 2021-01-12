#!/bin/sh
source ~/.zshrc
/usr/local/opt/node@12/bin/npm install -g newman
/usr/local/bin/ansible-vault decrypt ~/.ssh/id_rsa
