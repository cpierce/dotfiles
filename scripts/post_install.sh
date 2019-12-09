#!/bin/sh
source ~/.zshrc
/usr/local/bin/npm install -g newman
/usr/local/bin/ansible-vault decrypt ~/.ssh/id_rsa
