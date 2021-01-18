#!/bin/sh

# First Install Brew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

# Now packages for we use with Brew
brew install git
brew install wget
brew install tmate
brew install jq
brew install awscli
brew install s3cmd
brew install vim
brew install the_silver_searcher
brew install php@7.4
pecl install xdebug
brew install php-cs-fixer
brew install pwgen
brew install homebrew/php/phpunit
brew install nmap
brew install terraform
brew install ansible
brew install shellcheck
brew install watch
brew install node@12
brew install packer
brew install openconnect
brew install --cask virtualbox
brew install --cask vagrant
brew install --cask ngrok
brew install --cask 1password-cli
brew upgrade
brew upgrade --cask
