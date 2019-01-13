#!/bin/bash
# CSGO Dedicated Server run script

# First, run the upgrade script
csgo-update.sh

# update the addons and configuration files
rsync -avh /home/steam/csgo-addons/ /home/steam/csgo-dedicated/csgo/
rsync -avh /home/steam/csgo-files/ /home/steam/csgo-dedicated/csgo/

# start the dedicated server
exec /home/steam/csgo-dedicated/srcds_run \
	-game csgo -console -autoupdate \
	-steam_dir /home/steam/steamcmd/ \
	-steamcmd_script /home/steam/csgo-dedicated/csgo_update.txt \
	-usercon +fps_max $SRCDS_FPSMAX -tickrate $SRCDS_TICKRATE -port $SRCDS_PORT \
	-tv_port $SRCDS_TV_PORT -maxplayers_override $SRCDS_MAXPLAYERS -nomaster \
	+sv_setsteamaccount $SRCDS_TOKEN -net_port_try 1 \
	+rcon_password $SRCDS_RCONPW +sv_password $SRCDS_PW +sv_region $SRCDS_REGION \
	+game_type 1 +game_mode 0 +mapgroup mg_armsrace +map de_lake

