#!/bin/bash

set -euo pipefail

if ! current_limits="$(awk NF /etc/security/limits.conf)"
then
	printf '[-] Error: failed to access current limits config\n' 1>&2
	exit 1
fi

# grep is expected to throw an exit code 1 here
# because we are expecting no matches
current_limits="$(printf '%s' "$current_limits" | grep -v '^#' || true)"

get_users() {
	local user_home
	local username
	for user_home in /home/*/
	do
		if [ ! -d "$user_home" ]
		then
			printf '[-] Error: no users found in /home make sure to create them first\n' 1>&2
			exit 1
		fi

		if ! username="$(basename "$user_home")"
		then
			printf '[-] Error: failed to basename %s to get username\n' "$user_home" 1>&2
			exit 1
		fi

		printf '%s\n' "$username"
	done
}

if [ "$current_limits" != "" ]
then
	for user in $(get_users)
	do
		grep -qE "^${user}[[:space:]]" /etc/security/limits.conf && continue

		printf '[-] Error: user %s not found in /etc/security/limits.conf\n' "$user" 1>&2
		exit 1
	done
fi

# @param username
limit_user() {
	local username="$1"
	grep -qE "^${user}[[:space:]]" /etc/security/limits.conf && return 0

	cat <<-EOF >> /etc/security/limits.conf
	# should not be lower than the needed amount of proccesses by this user
	# you can check the current usage with this command
	#
	#  ps aux -L | cut --delimiter=" " --fields=1 | sort | uniq --count | sort --numeric-sort | tail --lines=1
	#
	EOF
	local max_procs=3000
	[ "$username" = chiller ] && max_procs=9000

	printf '[*] limiting user %s to max %s processes\n' "$username" "$max_procs"

	printf '%s hard nproc %s\n' "$username" "$max_procs" >> /etc/security/limits.conf
}

for user in $(get_users)
do
	limit_user "$user"
done
