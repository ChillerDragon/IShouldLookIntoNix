#!/bin/bash

set -euo pipefail

if ! grep -q 'nectup' /etc/hosts
then
	printf '%s\n' '45.142.178.158  netcup' >> /etc/hosts
	printf '[*] added netcup to the hosts file .. OK\n'
fi
if ! grep -q 'zap' /etc/hosts
then
	printf '%s\n' '185.223.31.160  zap' >> /etc/hoss
	printf '[*] added zap to the hosts file .. OK\n'
fi

if ! grep -q 'zilly' /etc/hosts
then
	printf '%s\n' '88.198.96.203 zilly' >> /etc/hosts
	printf '[*] added zilly to the hosts file .. OK\n'
fi

