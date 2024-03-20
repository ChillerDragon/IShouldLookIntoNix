#!/bin/bash
#
# usage: user.sh SSH_PUBLIC_KEY
#

set -euo pipefail

# shellcheck disable=1091
[ -f ./../.env ] && source ./../.env

# shellcheck disable=1091
[ -f ./.env ] && source ./.env

SSH_PUBLIC_KEY="${SSH_PUBLIC_KEY:-$1}"
if [ "$SSH_PUBLIC_KEY" = "" ]
then
	printf '%s\n' "usage: users.sh SSH_PUBLIC_KEY" 1>&2
	exit 1
fi

if ! grep -q '^admin:' /etc/group
then
	addgroup admin
	printf '[*] created admin group .. OK\n'
fi

if ! grep -q '^teeworlds:' /etc/passwd
then
	addgroup teeworlds
	adduser \
		--comment "" \
		--home /home/teeworlds \
		--shell /bin/bash \
		--disabled-password \
		--ingroup users teeworlds
	chown -R teeworlds:admin /home/teeworlds/
	chmod o-x /home/teeworlds/
	printf '[*] created user teeworlds .. OK\n'
fi

if [ ! -f /home/teeworlds/.ssh/authorized_keys ]
then
	mkdir -p /home/teeworlds/.ssh
	chown teeworlds:teeworlds /home/teeworlds/.ssh/
	printf '%s\n' "$SSH_PUBLIC_KEY" > /home/teeworlds/.ssh/authorized_keys
fi

if ! grep -q '^chiller:' /etc/passwd
then
	useradd \
		--shell /bin/bash \
		--create-home \
		--groups admin sudo \
		--home-dir /home/chiller chiller
	chmod o-x /home/chiller
	printf '[*] created user chiller .. OK\n'
fi

if [ ! -f /home/chiller/.ssh/authorized_keys ]
then
	mkdir -p /home/chiller/.ssh
	chown chiller:chiller /home/chiller/.ssh/
	printf '%s\n' "$SSH_PUBLIC_KEY" > /home/chiller/.ssh/authorized_keys
fi

printf '[*] done all users created.\n'

