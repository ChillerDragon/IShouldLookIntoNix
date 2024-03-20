#!/bin/bash

set -euo pipefail

if [ "$UID" = 0 ] || [ "$EUID" = 0 ]
then
  printf '[-] Error: this script can not be run as root.\n' 1>&2
  exit 1
fi

printf '[*] installing tools for user=%s uid=%d euid=%d\n' "$USER" "$UID" "$EUID"

GIT_HOST=git@github.com:
if [ "$USER" = teeworlds ]
then
	GIT_HOST=https://github.com/
fi

if [ ! -f ~/.ssh/known_hosts ]
then
	mkdir -p ~/.ssh
	cat <<-EOF > ~/.ssh/known_hosts
	# https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/githubs-ssh-key-fingerprints
	github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl
	github.com ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg=
	github.com ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCj7ndNxQowgcQnjshcLrqPEiiphnt+VTTvDP6mHBL9j1aNUkY4Ue1gvwnGLVlOhGeYrnZaMgRK6+PKCUXaDbC7qtbW8gIkhL7aGCsOr/C56SJMy/BCZfxd1nWzAOxSDPgVsmerOBYfNqltV9/hWCqBywINIR+5dIg6JTJ72pcEpEjcYgXkE2YEFXV1JHnsKgbLWNlhScqb2UmyRkQyytRLtL+38TGxkxCflmO+5Z8CSSNY7GidjMIZ7Q4zMjA2n1nGrlTDkzwDCsw+wqFPGQA179cnfGWOWRVruj16z6XyvxvjJwbz0wQZ75XK5tKSb7FNyeIEs4TT4jk+S4dhPeAUC5y+bDYirYgM4GC7uEnztnZyaVWQ7B381AK4Qdrwt51ZqExKbQpTUNn+EjqoTwvqNj4kqx5QUCI0ThS/YkOxJCXmPUWZbhjpCg56i+2aB6CmK2JGhn57K5mj0MNdBXA4/WnwH6XoPWJzK5Nyu2zB3nAZp+S5hpQs+p1vN1/wsjk=

	EOF
	printf '[*] added github.com to known hosts .. OK\n'
fi

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
    mkdir -p ~/git
    cd ~/git
    git clone "${GIT_HOST}ChillerDragon/dotfiles"
  fi
  if [ ! -d ~/git/crools ]
  then
    mkdir -p ~/git
    cd ~/git
    git clone "${GIT_HOST}ChillerDragon/crools"
  fi
  printf '[*] dotfiles .. OK\n'
}

install_rbenv
install_nvm
install_rustup
install_dotfiles

