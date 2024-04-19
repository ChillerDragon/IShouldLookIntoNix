#!/bin/bash

set -euo pipefail

for user in /home/*/
do
	[ -d "$user" ] && continue

	printf '[-] Error: no users found in /home make sure to create them first\n'
	exit 1
done

restricted_dirs=(/usr/games /usr/src /media /opt /srv /var)

printf '[*] removing read access for %s\n' "${restricted_dirs[*]}"
chown -R root:admin "${restricted_dirs[@]}"
chmod o-x "${restricted_dirs[@]}"
chmod o-r "${restricted_dirs[@]}"

printf '[*] disallow listing /home\n'
chmod o-x /home/*/
chmod o-r /home/
chown root:admin /home

printf '[*] harden /etc\n'
chmod o-r /etc
shopt -s extglob
chmod o-r /etc/!(mtab)
shopt -u extglob
chmod o-r /etc/.*
chmod o-x /etc/*/

printf '[*] allowing read access for /etc/alternatives and /etc/profile\n'
chmod o+x /etc/alternatives
chmod o+r /etc/profile

printf '[*] allow /etc/passwd for ssh and git\n'
chmod o+r /etc/passwd

printf '[*] allow dns for all users /etc/resolv.conf\n'
chmod o+r /etc/resolv.conf

printf '[*] allow access to ca certs for ssl /etc/ssl/certs/ca-certificates.crt\n'
chmod o+x /etc/ssl
chmod o+x /etc/ssl/certs
chmod o-r /etc/ssl/certs/*
chmod o+r /etc/ssl/certs/ca-certificates.crt

