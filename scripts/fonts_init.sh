#!/bin/zsh
if [[ "$(uname -s)" == "Darwin" ]]; then
  cp resources/fonts/* ~/Library/Fonts
else
  mkdir -p ~/.local/share/fonts
  cp resources/fonts/* ~/.local/share/fonts/
  fc-cache -f
fi

curl -sS https://webi.sh/nerdfont | sh; \
[ -f ~/.config/envman/PATH.env ] && source ~/.config/envman/PATH.env
