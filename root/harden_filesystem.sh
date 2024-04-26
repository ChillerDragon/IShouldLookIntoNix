#!/bin/bash

set -euo pipefail

for user in /home/*/
do
	[ -d "$user" ] && continue

	printf '[-] Error: no users found in /home make sure to create them first\n'
	exit 1
done

restricted_dirs=(/usr/games /usr/src /media /opt /srv)

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

printf '[*] harden /var\n'
chown root:admin /var
# allow cd /var because a lot of tools need it like _apt or www-data
# but disallow any sub directory
# they have to be whitelisted for the users
chmod o-x /var/*/
chmod o-r /var/

printf '[*] open /var/cache/apt\n'
chmod o+x /var/cache
chmod o+x /var/cache/apt

# https://askubuntu.com/a/908825
printf '[*] allow _apt user to use /var/cache\n'
chown -Rv _apt:root /var/cache/apt/archives/partial/
chmod -Rv 700 /var/cache/apt/archives/partial/

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

