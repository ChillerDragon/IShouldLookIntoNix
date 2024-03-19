#!/bin/bash

set -euo pipefail

cd ~

if [ ! -d tem-07 ]
then
	git clone git@github.com:DDNetPP/server.git tem-07
fi

cd ~/tem-07

mkdir -p stats
[ -d cfg ] || git clone git@github.com:chillavanilla/cfg.git
[ -d cfg/private ] || git clone git@github.com:chillavanilla/private.git cfg/private

if [ ! -f server.cnf ]
then
	printf '%s\n' "include ./cfg/private/07.cnf" > server.cnf
fi

if [ ! -f autoexec.cfg ]
then
	cat <<-EOF > autoexec.cfg
	# cfg repo template config
	#
	# SERVERNAME: tem07

	exec cfg/07.cfg
	
	EOF
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

	ln -s ../../tem-07/cfg/private/public7.settings .
	ln -s ../../tem-07/cfg/private/locked_names.json .
fi

cd ~/tem-07
if [ ! -d maps ]
then
	./lib/get_maps.sh --non-interactive --output-dir "$PWD/maps" --source "vanilla 0.7.1 release"
fi

cd ~/git
[ -d teeworlds ] || git clone --recursive git@github.com:teeworlds/teeworlds

cd ~/tem-07
if [ ! -f ./bin/vanilla7_srv ]
then
	# hack to trigger compile once for a tem server
	printf '%s\n' 'server_type=teeworlds' >> server.cnf
	./update.sh

	# TODO: this is never run because ./update.sh fails with exit code 1 always?!

	grep -v '^server_type=teeworlds' server.cnf > server.cnf.tmp
	mv server.cnf.tmp server.cnf

	mv ./bin/tem07 ./bin/vanilla7_srv
fi

