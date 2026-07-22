#!/bin/zsh

# First Install Brew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Load Homebrew into PATH for this session
if [ -x "/opt/homebrew/bin/brew" ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x "/usr/local/bin/brew" ]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# Now packages for we use with Brew
brew install 1password-cli
brew install ansible
brew install asitop
brew install --cask audacity
brew install awscli
brew install azure-cli
brew install buf
brew install --cask claude
brew install --cask codex
brew tap dart-lang/dart
brew install dart-lang/dart/dart
brew install direnv
brew install docker
brew install ffmpeg
brew install --cask gemini
brew install gemini-cli
brew install gh
brew install git
brew install gnupg2
brew install go
brew install fzf
brew install helm
brew install jq
brew install --cask jordanbaird-ice
brew tap cpierce/tap
brew install cpierce/tap/l8nc
brew install kubernetes-cli
brew install luarocks
brew install mkcert
brew install mysql-client
brew install ngrok
brew install nmap
brew install node
brew install openai-whisper
brew install pnpm
brew install php
brew install phpstan
brew install phpunit
brew install pinentry-mac
brew install poppler
brew install powershell
brew install pv
brew install pwgen
brew install python@3.13
brew install ripgrep
brew install rust
brew install s3cmd
brew tap sass/sass
brew install sass/sass/sass
brew install shellcheck
brew install sshpass
brew install starship
brew install sslscan
brew install tmate
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
brew install semgrep
brew install sequel-ace
brew install tree
brew install wimlib
brew install yt-dlp
brew install neovim
brew install watch
brew install wget
brew upgrade
