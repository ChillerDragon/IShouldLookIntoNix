#!/bin/bash
#
# diallow users seeing other users processes
# via for example the 'ps' command
#

set -euo pipefail

if [ "$(mount -l -t proc)" = "proc on /proc type proc (rw,nosuid,nodev,noexec,relatime,hidepid=invisible)" ]
then
  printf '[*] /proc is already hardened check with "ps aux" you should only see your processes .. OK\n'
else
  mount -o remount,rw,nosuid,nodev,noexec,relatime,hidepid=2 /proc
  printf '[*] mounted /proc with hidepid check with "ps aux" you should now only see your processes\n'
fi

proc_fstab='proc    /proc    proc    defaults,nosuid,nodev,noexec,relatime,hidepid=2     0     0'

if ! grep -q proc /etc/fstab
then
  printf '%s\n' "$proc_fstab" >> /etc/fstab
  printf '[*] added /proc hardening to /etc/fstab to persist across reboots\n'
else
  current_proc="$(grep proc /etc/fstab)"
  if [ "$current_proc" = "$proc_fstab" ]
  then
    printf '[*] /proc hardening already in /etc/fstab\n .. OK\n'
  else
    printf '[-] Error: unexpected /proc mount found in /etc/fstab .. ERROR\n' 1>&2
    printf '[-]        expected: %s\n' "$proc_fstab" 1>&2
    printf '[-]           found: %s\n' "$proc_fstab" 1>&2
  fi
fi

