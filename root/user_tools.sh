#!/bin/bash
#
# usage: user_tools.sh UNIX_USER
#

set -euo pipefail

UNIX_USER="${UNIX_USER:-${1:-}}"
if [ "$UNIX_USER" = "" ]
then
  printf '%s\n' "usage: user_tools.sh UNIX_USER" 1>&2
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

script_dst="/home/$UNIX_USER/install_tools.sh"
cp ./user/install_tools.sh "$script_dst" || \
  cp ../user/install_tools.sh "$script_dst"
chown "$UNIX_USER:$UNIX_USER" "$script_dst"

su - "$UNIX_USER" -c "/bin/bash $script_dst"

printf '[*] done all tools installed for user %s.\n' "$UNIX_USER"

