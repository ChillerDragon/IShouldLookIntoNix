#!/bin/bash

set -euo pipefail

restricted_dirs=(/usr /etc /media /opt /srv /var)

chown -R root:admin "${restricted_dirs[@]}"
chmod o-x "${restricted_dirs[@]}"
chmod o-r "${restricted_dirs[@]}"

