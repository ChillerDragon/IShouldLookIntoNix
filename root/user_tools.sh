#!/bin/bash
#
# usage: user_tools.sh UNIX_USER
#

set -euo pipefail

UNIX_USER="${1:-}"
if [ "$UNIX_USER" = "" ]
then
	printf '%s\n' "usage: user_tools.sh UNIX_USER" 1>&2
	exit 1
fi

if [[ "$UNIX_USER" =~ ^[a-z][a-z0-9]*$ ]]
then
	printf "[-] Error: invalid unix user name '%s' only [a-z] is allowed\n" "$UNIX_USER" 1>&2
	exit 1
fi

if ! grep -q "^$UNIX_USER:" /etc/passwd
then
	printf '[-] Error: unix user not found %s\n' "$UNIX_USER" 1>&2
	exit 1
fi

if [ ! -d "/home/$UNIX_USER" ]
then
	printf '[-] Error: directory not found /home/%s\n' "$UNIX_USER" 1>&2
	exit 1
fi

# also install the setup script into the the users home dir
# so it can be executed as the user there without root privileges
cd "/home/$UNIX_USER"
if [ ! -d setup-chiller-vps ]
then
	git clone git@github.com:ChillerDragon/setup-chiller-vps.git
fi
cd setup-chiller-vps
git pull
chown -R "$UNIX_USER:$UNIX_USER" "/home/$UNIX_USER/setup-chiller-vps"

su - "$UNIX_USER" -c "/bin/bash -c 'cd /home/$UNIX_USER/setup-chiller-vps && ./user/install_tools.sh'"

printf '[*] done all tools installed for user %s.\n' "$UNIX_USER"

