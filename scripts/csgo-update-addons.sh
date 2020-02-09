#!/bin/bash

if [[ ! -d "$CSGO_DIR/csgo/addons/" ]]; then
	rsync -avh /home/steam/csgo-addons/ "$CSGO_DIR/csgo/"
fi

