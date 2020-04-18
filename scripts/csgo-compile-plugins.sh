#!/bin/bash
# Downloads / compiles the requested CSGO addons and stores them on the image

set -e
SDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

source "$SDIR/lib/base-addons.sh"
source "$SDIR/lib/sourcemod.sh"

(
	cd "/home/steam/sm_addons_src/"
	shopt -s nullglob
	for plugsrc in *.sp; do
		sm_compile_install "$plugsrc"
	done
)

