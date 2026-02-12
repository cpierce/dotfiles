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
brew install awscli
brew install azure-cli
brew install copilot
brew install direnv
brew install docker
brew install ffmpeg
brew install git
brew install gnupg2
brew install fzf
brew install jq
brew install luarocks
brew install mkcert
brew install ngrok
brew install nmap
brew install node
brew install pnpm
brew install packer
brew install php
brew install phpstan
brew install phpunit
brew install pinentry-mac
brew install powershell
brew install pwgen
brew install ripgrep
brew install s3cmd
brew install shellcheck
brew install starship
brew install sslscan
brew install tmate
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
brew install sequel-ace
brew install tree
brew install yt-dlp
brew install neovim
brew install watch
brew install wget
brew upgrade
