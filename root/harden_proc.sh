#!/bin/bash
#
# diallow users seeing other users processes
# via for example the 'ps' command
#

set -euo pipefail

admin_gid=''
if ! grep -q '^admin:' /etc/group
then
	printf '[*] created admin group .. OK\n'
	groupadd admin
fi
if ! admin_gid="$(grep '^admin:' /etc/group | cut -d':' -f3)"
then
	printf '[-] Error: failed to get admin group id .. ERROR\n' 1>&2
	exit 1
fi
if [[ ! "$admin_gid" =~ ^[0-9]+$ ]]
then
	printf '[-] Error: got invalid admin group id '%s'\n' "$admin_gid" 1>&2
	exit 1
fi
if [ "$admin_gid" -lt 1000 ]
then
	printf '[-] Error: got admin group id '%s' that is too low (expected 1000+)\n' "$admin_gid" 1>&2
	exit 1
fi

if [ "$(mount -l -t proc)" = "proc on /proc type proc (rw,nosuid,nodev,noexec,relatime,gid=$admin_gid,hidepid=invisible)" ]
then
	printf '[*] /proc is already hardened check with "ps aux" you should only see your processes .. OK\n'
else
	mount -o "remount,rw,nosuid,nodev,noexec,relatime,hidepid=2,gid=$admin_gid" /proc
	printf '[*] mounted /proc with hidepid check with "ps aux" you should now only see your processes\n'
fi

read -r -d '' proc_fstab << EOF || true
proc /proc        proc    defaults,nosuid,nodev,noexec,relatime,hidepid=2,gid=$admin_gid     0     0
EOF

if ! grep -q proc /etc/fstab
then
	printf '%s\n' "$proc_fstab" >> /etc/fstab
	printf '[*] added /proc hardening to /etc/fstab to persist across reboots\n'
else
	current_proc="$(grep proc /etc/fstab)"
	if [ "$current_proc" = "$proc_fstab" ]
	then
		printf '[*] /proc hardening already in /etc/fstab .. OK\n'
	else
		printf '[-] Error: unexpected /proc mount found in /etc/fstab .. ERROR\n' 1>&2
		printf '[-]        expected: %s\n' "$proc_fstab" 1>&2
		printf '[-]           found: %s\n' "$proc_fstab" 1>&2
	fi
fi

