#!/bin/bash
#

set -euo pipefail

SSH_PORT="${SSH_PORT:-$1}"

printf 'Port %d\n' > /etc/ssh/sshd_config.d/chiller.conf
