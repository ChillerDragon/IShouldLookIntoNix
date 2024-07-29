#!/bin/bash
# ger8

set -euo pipefail

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

	sv_name "ChillerDragon's gCTF/iCTF GER8 [0.6/0.7 bridge]"
	sv_port 8303
	EOF
fi
if [ ! -f server.cnf ]
then
	cat <<-EOF > server.cnf
	include cfg/server.cnf
	gitpath_log=/home/chiller/git/TeeworldsLogsXXXXYY
	server_name=ddnet-gctf1
	EOF
fi

mkdir ~/git
cd ~/git

[ -d ddnet-insta ] || git clone git@github.com:ZillyInsta/ddnet-insta.git

