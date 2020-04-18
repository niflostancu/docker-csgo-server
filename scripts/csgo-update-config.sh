#!/bin/bash
# Updates the CSGO volume configs with the ones stored in the image

set -e
SDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

if [[ -n "$STEAM_API_KEY" ]]; then
	echo "$STEAM_API_KEY" > "$CSGO_DIR/csgo/webapi_authkey.txt"
fi

# manage addons
source "$SDIR/lib/base-addons.sh"
update_metamod
update_sourcemod

# update image configs
echo "Updating server configs..."
rsync -ai /home/steam/csgo-files/ "$CSGO_DIR"/csgo/

if [[ -d "/home/steam/csgo-overrides/" ]]; then
	echo "Updating server config overrides..."
	rsync -ai /home/steam/csgo-overrides/ "$CSGO_DIR"/csgo/
fi

