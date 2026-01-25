#!/bin/zsh
cp resources/fonts/* ~/Library/Fonts

curl -sS https://webi.sh/nerdfont | sh; \
[ -f ~/.config/envman/PATH.env ] && source ~/.config/envman/PATH.env
