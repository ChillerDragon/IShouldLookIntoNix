#!/bin/bash

set -euo pipefail

cd ~

if [ ! -d tem-07 ]
then
	git clone git@github.com:DDNetPP/server.git tem-07
fi
cd tem-07

[ -d cfg ] || git clone git@github.com:chillavanilla/cfg.git
[ -d cfg/private ] || git clone git@github.com:chillavanilla/private.git cfg/private

if [ ! -f server.cnf ]
then
	printf '%s\n' "include ./cfg/private/07.cnf" > server.cnf
fi

mkdir -p ~/git
cd ~/git

[ -d TeeworldsEconMod ] || git clone git@github.com:chillavanilla/TeeworldsEconMod.git
cd TeeworldsEconMod
if [ ! -d venv ]
then
	python3 -m venv venv
	# shellcheck disable=1091
	source venv/bin/activate
	if ! pip freeze | grep -q requests
	then
		pip install -r requirements.txt
	fi

	# TODO: symlinks
	ln -s ../../tem-07/cfg/private/public7.settings .
fi

if [ ! -d maps ]
then
	./lib/get_maps.sh --non-interactive --output-dir maps --source "vanilla 0.7.1 release"
fi
