#!/bin/bash

set -euo pipefail

restricted_dirs=(/usr/games /usr/src /etc /media /opt /srv /var)

printf '[*] removing read access for %s\n' "${restricted_dirs[*]}"
chown -R root:admin "${restricted_dirs[@]}"
chmod o-x "${restricted_dirs[@]}"
chmod o-r "${restricted_dirs[@]}"

printf '[*] allwowing read access for /etc/alternatives and /etc/profile\n'
chmod o+r /etc/alternatives
chmod o+r /etc/profile

