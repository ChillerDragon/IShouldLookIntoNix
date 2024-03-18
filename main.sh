#!/bin/bash

set -euo pipefail

printf 'enter your ssh public key:\n'
read -e -r -p '> ' SSH_PUBLIC_KEY

./packages.sh
./firewall.sh
./user.sh "$SSH_PUBLIC_KEY"
./harden_filesystem.sh
./harden_proc.sh

if [ ! -f /root/.ssh/authorized_keys ]
then
  mkdir -p /root/.ssh
  printf '%s\n' "$SSH_PUBLIC_KEY" >> /root/.ssh/authorized_keys
fi

