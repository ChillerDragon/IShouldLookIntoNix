#!/bin/bash

set -eu

packages=(
  sudo
  adduser binutils-dev
  cmake make build-essential gdb clang
  conntrack
  cron
  dnsutils
  figlet
  luarocks shellcheck
  curl wget
  tmux screen
  git htop tree vim-nox
  universal-ctags
  glslang-tools
  google-mock
  iptables
  iptables-persistent
  libavcodec-extra
  libavdevice-dev
  libavfilter-dev
  libavformat-dev
  libavutil-dev
  libboost-dev
  libcurl4-openssl-dev
  libfreetype6-dev
  libglew-dev
  mariadb-client
  libmariadb-dev
  libmariadb-dev-compat
  libmaxminddb-dev
  libmysqlcppconn-dev
  libnl-genl-3-dev
  libnotify-dev
  libogg-dev
  libopus-dev
  libopusfile-dev
  libpcap-dev
  libpng-dev
  libreadline-dev
  libsdl2-dev
  libsqlite3-dev
  libssl-dev
  libvulkan-dev
  libwavpack-dev
  libwebsockets-dev
  libx264-dev
  mariadb-client
  net-tools
  pkg-config
  python3
  python3-cachetools
  python3-dev
  python3-dnslib
  python3-pip
  rsync
  spirv-tools
  sqlite3
  unzip
  strace
  tcpdump nload
  bc
)

# cache might contain removed packages
# but at least it is fast
apt_list="$(apt-cache search . | cut -d' ' -f1)"
have_all=1
for package in "${packages[@]}"
do
	# this breaks with set -o pipefail
	if ! printf '%s\n' "$apt_list" | grep -qxF "$package"
	then
		printf "[*] missing package '%s'. Installing ...\n" "$package"
		have_all=0
		break
	fi
done

if [ "$have_all" = 1 ]
then
	printf '[*] all packages already installed .. OK\n'
	exit 0
fi

apt-get -y update
apt-get -y upgrade

apt-get -y install netcat || apt-get -y install netcat-openbsd

apt-get -y install "${packages[@]}"

