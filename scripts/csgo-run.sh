#!/bin/bash
# CSGO Dedicated Server run script

set -e
SDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# First, run the upgrade script
"$SDIR/csgo-update.sh"

# update the addons
"$SDIR/csgo-update-config.sh"

# start the dedicated server
cd "$CSGO_DIR"
ln -sf /home/steam/steamcmd/steamcmd.sh /home/steam/steamcmd/steam.sh
exec "$CSGO_DIR"/srcds_run \
	-game csgo -console -autoupdate \
	-steam_dir /home/steam/steamcmd/ \
	-steamcmd_script "$CSGO_DIR"/csgo_update.txt \
	-usercon +fps_max $SRCDS_FPSMAX -tickrate $SRCDS_TICKRATE -port $SRCDS_PORT \
	-tv_port $SRCDS_TV_PORT -maxplayers_override $SRCDS_MAXPLAYERS -nomaster \
	+sv_setsteamaccount $SRCDS_TOKEN -net_port_try 1 \
	+rcon_password $SRCDS_RCONPW +sv_password $SRCDS_PW +sv_region $SRCDS_REGION \
	$SRCDS_STARTUP_SCRIPT

