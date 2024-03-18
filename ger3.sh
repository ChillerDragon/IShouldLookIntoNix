#!/bin/bash

set -euo pipefail

# tem-07

cd ~

if [ ! -d tem-07 ]
then
	git clone git@github.com:DDNetPP/server.git tem-07
fi
cd tem-07

[ -d cfg ] || git clone git@github.com:chillavanilla/cfg.git
[ ! -d cfg/private ] || git clone git@github.com:chillavanilla/private.git cfg/private
if [ -d maps ]
then
	# TODO: this is wrong we need the release archive or correct git checkout
	#       use ./lib/get_maps.sh but it needs to be updated first to allow non interactive
	git clone git@github.com:teeworlds/teeworlds-maps.git maps
fi

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
fi

# gctf1

cd ~

if [ ! -d gctf1 ]
then
	git clone git@github.com:DDNetPP/server.git gctf1
fi
cd gctf1

[ -d cfg ] || git clone git@github.com:ZillyInsta/cfg.git
[ -d maps ] || git clone git@github.com:ZillyInsta/maps-06.git maps
[ -d maps7 ] || git clone git@github.com:ZillyInsta/maps-07.git maps7

if [ ! -f autoexec.cfg ]
then
	cat <<-EOF > autoexec.cfg
	# ddnet gctf
	exec cfg/autoexec.cfg

	sv_name "ChillerDragon's gCTF/iCTF GER1 [0.6/0.7 bridge]"
	sv_port 8709
	EOF
fi
if [ ! -f server.cnf ]
then
	cat <<-EOF > server.cnf
	include cfg/server.cnf
	server_name=ddnet-gctf1
	EOF
fi

mkdir ~/git
cd ~/git

[ -d ddnet-insta ] || git clone git@github.com:ZillyInsta/ddnet-insta.git

