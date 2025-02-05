#!/bin/zsh
cp resources/fonts/* ~/Library/Fonts

curl -sS https://webi.sh/nerdfont | sh; \
source ~/.config/envman/PATH.env
