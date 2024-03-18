#!/bin/bash

set -euo pipefail

if [ "$UID" = 0 ] || [ "$EUID" = 0 ]
then
  printf '[-] Error: this script can not be run as root.\n' 1>&2
  exit 1
fi

printf '[*] installing tools for user=%s uid=%d euid=%d\n' "$USER" "$UID" "$EUID"

install_rbenv() {
  if [ ! -d ~/.rbenv ]
  then
    git clone https://github.com/rbenv/rbenv.git ~/.rbenv
  fi
  if ! grep -q rbenv ~/.bashrc
  then
    # shellcheck disable=2016
    echo 'eval "$(~/.rbenv/bin/rbenv init - bash)"' >> ~/.bashrc
  fi

  if [ ! -d ~/.rbenv/plugins/ruby-build ]
  then
    git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
  fi
  printf '[*] rbenv .. OK\n'
}

install_nvm() {
  if [ ! -d ~/.nvm ]
  then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
  fi
  printf '[*] nvm .. OK\n'
}

install_rustup() {
  if [ ! -d ~/.rustup ]
  then
    curl https://sh.rustup.rs -sSf | sh -s -- -y
  fi
  printf '[*] rustup .. OK\n'
}

install_dotfiles() {
  if [ ! -d ~/git/dotfiles ]
  then
    mkdir ~/git
    cd ~/git
    git clone git@github.com:ChillerDragon/dotfiles
  fi
  if [ ! -d ~/git/crools ]
  then
    mkdir ~/git
    cd ~/git
    git clone git@github.com:ChillerDragon/crools
  fi
  printf '[*] dotfiles .. OK\n'
}

install_rbenv
install_nvm
install_rustup
install_dotfiles

