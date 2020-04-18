#!/bin/bash

set -e
VALIDATE=validate
if [[ -d "$CSGO_DIR/csgo" ]]; then
	VALIDATE=
fi

# Install / update CSGO
/home/steam/steamcmd/steamcmd.sh +login anonymous \
	+force_install_dir "$CSGO_DIR" \
	+app_update 740 $VALIDATE \
	+quit

{ \
	echo '@ShutdownOnFailedCommand 1'
	echo '@NoPromptForPassword 1'
	echo 'login anonymous'
	echo 'force_install_dir /home/steam/csgo-dedicated'
	echo 'app_update 740'
	echo 'quit'
} > "$CSGO_DIR"/csgo_update.txt

