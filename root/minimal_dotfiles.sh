#!/bin/bash

set -euo pipefail

if grep -q 'export EDITOR=vim' ~/.bashrc
then
  printf '[*] EDITOR already set in bashrc skipping minimal dotfiles .. OK\n'
  exit 0
fi

printf 'export EDITOR=vim' >> ~/.bashrc
if ! grep -q '^alias x' ~/.bashrc
then
  printf "alias x='ls && git status'" >> ~/.bashrc
  printf '[*] set x alias .. OK\n'
fi

if [ ! -f /usr/bin/git ]
then
  apt-get install -y git
fi

if [ "$(git config --global user.name)" = "" ]
then
  git config --global user.name ChillerDragon
fi
if [ "$(git config --global user.email)" = "" ]
then
  git config --global user.email chillerdragon@gmail.com
fi

