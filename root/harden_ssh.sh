#!/bin/bash
# harden_ssh.sh

set -euo pipefail

# shellcheck disable=1091
[ -f ./../.env ] && source ./../.env

# shellcheck disable=1091
[ -f ./.env ] && source ./.env

SSH_PORT="${SSH_PORT:-$1}"
if [[ ! "$SSH_PORT" =~ ^[0-9]+$ ]]
then
	printf '[-] Error: invalid ssh port %s\n' "$SSH_PORT" 1>&2
	exit 1
fi
if [ "$SSH_PORT" = 22 ]
then
	printf '[!] Warning: using default ssh port %s\n' "$SSH_PORT" 1>&2
	exit 0
fi

if grep -q '^[[:space:]]*Port[[:space:]]' /etc/ssh/sshd_config
then
	printf '[-] Error: failed to set custom ssh port because there is one set already\n' 1>&2
	printf '[-]        check your /etc/ssh/sshd_config file and remove all occurences of "Port xxx"\n' 1>&2
	exit 1
fi

cust_ssh_conf=/etc/ssh/sshd_config.d/chiller.conf
if [ -f "$cust_ssh_conf" ]
then
	if ! grep -q "Port $SSH_PORT" "$cust_ssh_conf"
	then
		printf '[-] Error: invalid ssh port configured expected %d check this file %s\n' "$SSH_PORT" "$cust_ssh_conf" 1>&2
		exit 1
	else

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
		  printf '[-] Error: ssh port configured correctly as %d\n' "$SSH_PORT" 1>&2
		  printf '[-]        but your currently running ssh server uses %s\n' "$current_ssh_port" 1>&2
		  printf '[-]        please reboot the server\n' 1>&2
		  exit 1
		fi


		printf '[*] ssh port set to %d .. OK\n' "$SSH_PORT"
	fi
else
	printf 'Port %d\n' "$SSH_PORT" > "$cust_ssh_conf"
	printf '[*] set ssh port to %s please reboot the server\n' "$SSH_PORT"
fi

