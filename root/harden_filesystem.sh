#!/bin/bash

set -euo pipefail

restricted_dirs=(/usr/games /usr/src /media /opt /srv /var)

printf '[*] removing read access for %s\n' "${restricted_dirs[*]}"
chown -R root:admin "${restricted_dirs[@]}"
chmod o-x "${restricted_dirs[@]}"
chmod o-r "${restricted_dirs[@]}"

printf '[*] disallow listing /home\n'
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
chmod o+r /etc/alternatives
chmod o+r /etc/profile

