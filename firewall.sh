#!/bin/bash

set -euo pipefail

SSH_PORT="${SSH_PORT:-$1}"
[ "$SSH_PORT" = "" ] && SSH_PORT=22

if [[ "$SSH_PORT" =~ ^[0-9]+$ ]]
then
  printf '[-] Error: invalid ssh port %s\n' "$SSH_PORT" 1>&2
  exit 1
fi

backup_file="/root/iptables_save_$(date '+%F-%H-%M_%s').txt"
iptables-save > "$backup_file"

printf '[*] backed up iptables to %s\n' "$backup_file"

# delete all current rules
iptables --flush
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -p udp 8303 -j ACCEPT
iptables -A INPUT -p tcp --dport "$SSH_PORT" -j ACCEPT
iptables -A INPUT -p tcp -j DROP

