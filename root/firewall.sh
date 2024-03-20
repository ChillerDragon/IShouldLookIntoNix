#!/bin/bash

set -euo pipefail

# shellcheck disable=1091
[ -f ./../.env ] && source ./../.env

# shellcheck disable=1091
[ -f ./.env ] && source ./.env

SSH_PORT="${SSH_PORT:-$1}"
[ "$SSH_PORT" = "" ] && SSH_PORT=22

if [[ "$SSH_PORT" =~ ^[0-9]+$ ]]
then
  printf '[-] Error: invalid ssh port %s\n' "$SSH_PORT" 1>&2
  exit 1
fi

if ! current_ssh_port="$(netstat -tulpn | grep ssh | awk '{ print $4 }' | cut -d':' -f2 | awk NF | head -n1)"
then
  printf '[-] Error: failed to detect ssh port. Make sure netstat is installed.\n' 1>&2
  exit 1
fi
if [ "$current_ssh_port" = "" ]
then
  printf '[-] Error: failed to detect ssh port. Please check the code of this script\n' 1>&2
  exit 1
fi
if [ "$current_ssh_port" != "$SSH_PORT" ]
then
  printf '[-] Error: is your ssh server really running on %d\n' "$SSH_PORT" 1>&2
  printf '[-]        detected ssh server running on port %d\n' "$current_ssh_port" 1>&2
  exit 1
fi

backup_file="/root/iptables_save_$(date '+%F-%H-%M_%s').txt"
iptables-save > "$backup_file"

printf '[*] backed up iptables to %s\n' "$backup_file"
printf '[*] whitelisting ssh port %d\n' "$SSH_PORT"

# yikes
update-alternatives --set iptables /usr/sbin/iptables-legacy

# deletes all current rules
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT
iptables -t nat -F
iptables -t mangle -F
iptables -F
iptables -X
iptables -t raw -A PREROUTING -p udp -j NOTRACK
iptables -t raw -A OUTPUT -p udp -j NOTRACK
iptables -N serverinfo
iptables -N newconn
iptables -A INPUT -p udp -m u32 --u32 "38=0x67696533" -j serverinfo
iptables -A INPUT -p udp -m u32 --u32 "38=0x66737464" -j serverinfo
iptables -A INPUT -p udp -m u32 --u32 "32=0x544b454e" -j newconn
iptables -A serverinfo -s 37.187.108.123 -j ACCEPT
iptables -A serverinfo -m hashlimit --hashlimit-above 100/s --hashlimit-burst 250 --hashlimit-mode dstport --hashlimit-name si_dstport -j DROP
iptables -A serverinfo -m hashlimit --hashlimit-above 20/s --hashlimit-burst 100 --hashlimit-mode srcip --hashlimit-name si_srcip -j DROP
iptables -A newconn -m hashlimit --hashlimit-above 100/s --hashlimit-burst 100 --hashlimit-mode dstport --hashlimit-name nc_dstport -j DROP
iptables -A INPUT -s 127.0.0.1 -j ACCEPT
iptables -A INPUT -p tcp -m tcp -m conntrack -m multiport --ctstate NEW ! --dports "$SSH_PORT" -j DROP
iptables -A INPUT -p udp -m udp --dport 8303 -j ACCEPT
iptables -A INPUT -p udp -m udp --dport 8709 -j ACCEPT
iptables -A INPUT -p udp -m udp --dport 53 -j ACCEPT
iptables -A INPUT -p udp -j DROP


