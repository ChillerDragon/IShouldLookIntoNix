#!/bin/bash

set -euo pipefail

# shellcheck disable=1091
[ -f ./../.env ] && source ./../.env

# shellcheck disable=1091
[ -f ./.env ] && source ./.env

SSH_PORT="${SSH_PORT:-$1}"
[ "$SSH_PORT" = "" ] && SSH_PORT=22

if [[ ! "$SSH_PORT" =~ ^[0-9]+$ ]]
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

if iptables-save | grep -qE '(docker|tun)'
then
	printf '[-] Error: skipping firewall setup because docker or a vpn is detected' 1>&2
	printf '[-]        there is no support for docker or vpns yet with the current firewall' 1>&2
	exit 1
fi

if [ -f /etc/iptables/rules.v4 ] &&
	grep -qF '0x20=0x544b454e' /etc/iptables/rules.v4 &&
	grep -qF "dports $SSH_PORT -j DROP" /etc/iptables/rules.v4
then
	cat <<-EOF
	[*] iptables already saved .. OK
	[*] if they do not show up in iptables -L try rebooting the server
	[*] to force recreate run the following command:

	  rm /etc/iptables/rules.v4 /etc/iptables/rules.v6

	EOF
	exit 0
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
iptables -I INPUT -s 147.251.0.0/16 -j DROP
iptables -I OUTPUT -d 147.251.0.0/16 -j DROP
iptables -A INPUT -s 127.0.0.1 -j ACCEPT
iptables -A INPUT -p tcp -m tcp -m conntrack -m multiport --ctstate NEW ! --dports "$SSH_PORT" -j DROP
iptables -A INPUT -p udp -m udp --dport 8303 -j ACCEPT
iptables -A INPUT -p udp -m udp --dport 8709 -j ACCEPT
iptables -A INPUT -p udp -m udp --dport 53 -j ACCEPT
iptables -A INPUT -p udp -m udp --sport 53 -j ACCEPT
iptables -A INPUT -p udp -j DROP


if [ -s /etc/iptables/rules.v4 ] || [ -s /etc/iptables/rules.v6 ]
then
	cat <<-EOF 1>&2
	[-] Error: /etc/iptables/rules.v4 or /etc/iptables/rules.v6 already exists
	[-]        not overwriting. iptables are not saved accross reboots
	[-]        to force recreate run the following command:

	  rm /etc/iptables/rules.v4 /etc/iptables/rules.v6

	EOF
	exit 1
fi

# check for errors before writing
iptables-save > /dev/null
ip6tables-save > /dev/null

iptables-save > /etc/iptables/rules.v4
ip6tables-save > /etc/iptables/rules.v6

printf '[*] iptables written to /etc/iptables/rules.v4\n'
printf '[*] iptables written to /etc/iptables/rules.v6\n'
printf '[*] iptables saved across reboots .. OK\n'

