#!/bin/bash

set -euo pipefail

restricted_dirs=(/usr/games /usr/src /etc /media /opt /srv /var)

chown -R root:admin "${restricted_dirs[@]}"
chmod o-x "${restricted_dirs[@]}"
chmod o-r "${restricted_dirs[@]}"

chmod o+r /etc/alternatives
chmod o+r /etc/profile

