#!/bin/bash

VALIDATE=validate
if [[ -d "/home/steam/csgo-dedicated/csgo" ]]; then
	VALIDATE=
fi

# Install / update CSGO
/home/steam/steamcmd/steamcmd.sh +login anonymous \
	+force_install_dir /home/steam/csgo-dedicated \
	+app_update 740 $VALIDATE \
	+quit

{ \
	echo '@ShutdownOnFailedCommand 1'; \
	echo '@NoPromptForPassword 1'; \
	echo 'login anonymous'; \
	echo 'force_install_dir /home/steam/csgo-dedicated/'; \
	echo 'app_update 740'; \
	echo 'quit'; \
} > /home/steam/csgo-dedicated/csgo_update.txt

