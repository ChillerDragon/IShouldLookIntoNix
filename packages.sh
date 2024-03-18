#!/bin/bash

apt-get -y update
apt-get -y upgrade

packages=(
  adduser binutils-dev
  cargo rustc cmake make build-essential gdb
  conntrack
  cron
  dnsutils
  curl wget
  git htop tree vim
  tmux screen
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
  python3-dnslib
  python3-pip
  rsync
  spirv-tools
  sqlite3
  strace
  tcpdump
  unzip
)

apt-get -y install "${packages[@]}"

