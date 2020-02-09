#!/bin/bash
# CSGO Dedicated Server run script

# First, run the upgrade script
csgo-update.sh

# update the addons
csgo-update-addons.sh

# update config
rsync -avh /home/steam/csgo-files/ "$CSGO_DIR"/csgo/
rsync -avh /home/steam/csgo-override/ "$CSGO_DIR"/csgo/

if [[ -n "$STEAM_API_KEY" ]]; then
	echo "$STEAM_API_KEY" > "$CSGO_DIR/csgo/webapi_authkey.txt"
fi

# start the dedicated server
cd "$CSGO_DIR"
ln -s /home/steam/steamcmd/steamcmd.sh /home/steam/steamcmd/steam.sh
exec "$CSGO_DIR"/srcds_run \
	-game csgo -console -autoupdate \
	-steam_dir /home/steam/steamcmd/ \
	-steamcmd_script "$CSGO_DIR"/csgo_update.txt \
	-usercon +fps_max $SRCDS_FPSMAX -tickrate $SRCDS_TICKRATE -port $SRCDS_PORT \
	-tv_port $SRCDS_TV_PORT -maxplayers_override $SRCDS_MAXPLAYERS -nomaster \
	+sv_setsteamaccount $SRCDS_TOKEN -net_port_try 1 \
	+rcon_password $SRCDS_RCONPW +sv_password $SRCDS_PW +sv_region $SRCDS_REGION \

