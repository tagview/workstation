#!/bin/sh

# If any command fails, we should immediately fail too
set -e

add_to_bash_profile() {
  if ! grep --quiet "$1" $PROFILE; then
    echo "$1" >> $PROFILE
  fi
}

refresh_session_profile() {
  if [ -f $PROFILE ]; then
    . $PROFILE
  fi
}

install_rbenv() {
  if ! command -v rbenv >/dev/null; then
    git clone https://github.com/rbenv/rbenv.git ~/.rbenv
    git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build

    add_to_bash_profile 'export PATH="$HOME/.rbenv/bin:$PATH"'
    add_to_bash_profile 'eval "$(rbenv init -)"'

    if ! grep --quiet "gem: --no-document" ~/.gemrc; then
      echo "gem: --no-document" >> ~/.gemrc
    fi
  else
    echo "rbenv already installed. Skipping..."
  fi
}

install_ruby() {
  local version="$1"

  eval "$(rbenv init -)"
  rbenv install -s "$version"
  rbenv global "$version"
  rbenv shell "$version"

  if ! command -v bundle >/dev/null; then
    gem install bundler
    rbenv rehash
    cores=$(nproc)
    bundle config --global jobs $((cores - 1))
    bundle config --global path vendor/ruby
    bundle config --global bin .bin

    add_to_bash_profile 'export PATH=".bin:bin:$PATH"'
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

install_yarn() {
  if ! command -v yarn >/dev/null; then
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
    sudo apt-get update && sudo apt-get install --no-install-recommends yarn
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

setup_profile() {
  export PROFILE=$1
  touch $PROFILE
  echo "source $PROFILE" >> ~/.bashrc
}

setup_profile ~/.bash_profile

sudo apt-get update

sudo apt-get install -y \
  apt-transport-https \
  build-essential \
  bison \
  automake \
  autoconf \
  pkg-config \
  curl \
  git \
  libffi-dev \
  libgdbm-dev \
  libncurses5-dev \
  libreadline-dev \
  libssl-dev \
  libyaml-dev \
  openssl \
  sqlite3 \
  libsqlite3-dev \
  libssl-dev \
  zlib1g \
  zlib1g-dev \
  php \
  php-curl

install_rbenv
install_ruby 2.4.2

install_nvm
nvm install node
install_yarn

install_arcanist
