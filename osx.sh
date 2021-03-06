#!/bin/sh

# If any command fails, we should immediately fail too
set -e

add_to_bash_profile() {
  if ! grep --quiet "$1" ~/.bash_profile; then
    echo "$1" >> ~/.bash_profile
  fi
}

refresh_session_profile() {
  . ~/.bash_profile
}

install_homebrew() {
  if ! command -v brew >/dev/null; then
    echo "Installing Homebrew"

    curl --silent \
         --fail \
         --show-error \
         --location \
         https://raw.githubusercontent.com/Homebrew/install/master/install | ruby

    add_to_bash_profile 'export PATH="/usr/local/bin:$PATH"'
    export PATH="/usr/local/bin:$PATH"

    brew doctor
  else
    echo "Homebrew already installed. Skipping..."
  fi
}

brew_install() {
  local formula="$1"

  if ! brew list | grep --quiet --line-regexp "$formula"; then
    echo "Installing formula $formula"
    brew install "$formula"
  else
    echo "Formula $formula already installed. Skipping..."
  fi
}

install_rbenv() {
  if ! command -v rbenv >/dev/null; then
    brew_install rbenv
    brew_install ruby-build
    add_to_bash_profile 'eval "$(rbenv init - --no-rehash)"'
  else
    echo "rbenv already installed. Skipping..."
  fi
}

install_ruby() {
  local version="$1"

  install_rbenv

  brew_install openssl
  brew_install libyaml
  brew_install readline
  brew_install libxml2
  brew link --force libxml2
  brew_install libxslt
  brew link --force libxslt

  eval "$(rbenv init -)"
  rbenv install -s "$version"
  rbenv global "$version"
  rbenv shell "$version"

  if ! command -v bundle >/dev/null; then
    gem install bundler
    rbenv rehash
    cores=$(sysctl -n hw.ncpu)
    bundle config --global jobs $((cores - 1))
    bundle config --global path vendor/ruby
    bundle config --global bin .bin

    add_to_bash_profile 'export PATH=".bin:bin:$PATH"'

    # Fix Nokogiri install by using brewed libxml2 and libxslt instead of iconv
    add_to_bash_profile "export NOKOGIRI_USE_SYSTEM_LIBRARIES=1"
  fi
}

install_nvm() {
  if ! command -v nvm >/dev/null; then
    echo "Installing nvm"

    curl --silent \
         --fail \
         --show-error \
         --location \
         https://raw.githubusercontent.com/creationix/nvm/v0.33.6/install.sh | bash

    refresh_session_profile
  else
    echo "nvm already installed. Skipping..."
  fi
}

install_node() {
  local version="$1"

  install_nvm

  nvm install "$version"
}

install_yarn() {
  if ! brew list | grep --quiet --line-regexp yarn; then
    echo "Installing yarn"
    brew install yarn --without-node
  else
    echo "Yarn already installed. Skipping..."
  fi
}

install_arcanist() {
  if ! [ -d ~/.phabricator ]; then
    mkdir ~/.phabricator
    git clone https://github.com/phacility/libphutil.git ~/.phabricator/libphutil
    git clone https://github.com/phacility/arcanist.git ~/.phabricator/arcanist
    add_to_bash_profile 'export PATH="$HOME/.phabricator/arcanist/bin:$PATH"'
  fi
}

setup_launchctl() {
  local service="$1"
  local domain="homebrew.mxcl.$service"
  local plist="$domain.plist"
  local launchctl_file="$HOME/Library/LaunchAgents/$plist"

  mkdir -p ~/Library/LaunchAgents

  if [ ! -e "$launchctl_file" ]; then
    echo "Setting up launchctl for $service"

    cp "/usr/local/opt/$service/$plist" ~/Library/LaunchAgents

    if launchctl list | grep -Fq "$domain"; then
      launchctl unload "$launchctl_file" >/dev/null
    fi

    launchctl load "$launchctl_file" >/dev/null
  else
    echo "Launchctl already configured for $service. Skipping..."
  fi
}

install_homebrew

brew_install git
brew_install postgresql
brew_install mysql
brew_install redis
brew_install sqlite
brew_install memcached
brew_install vim
brew_install imagemagick
brew_install watch
brew_install tree
brew_install heroku/brew/heroku

install_arcanist

setup_launchctl postgresql
setup_launchctl mysql
setup_launchctl memcached
setup_launchctl redis

install_ruby 2.4.2
install_node 8
install_yarn

# Fast keyboard repeat rate
defaults write NSGlobalDomain KeyRepeat -int 2

# Shorter delay until key repeat
defaults write NSGlobalDomain InitialKeyRepeat -int 20

# Enable inspect element in web views
defaults write NSGlobalDomain WebKitDeveloperExtras -bool true

# Allow using tabs to cycle between prompts buttons
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

# Show the ~/Library folder
chflags nohidden ~/Library

# Always show file extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Don't create DS_Store when connecting to network volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

# Don't always ask for using connected external drive with Timemachine
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

# Turn off keyboard illumination when it is not touched for five minutes
defaults write com.apple.BezelServices kDimTime -int 300
