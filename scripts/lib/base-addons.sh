#!/bin/bash
# Functions for HL addon management

# Update the URLs
METAMOD_URL="https://mms.alliedmods.net/mmsdrop/1.10/mmsource-1.10.7-git971-linux.tar.gz"
SOURCEMOD_URL="https://sm.alliedmods.net/smdrop/1.10/sourcemod-1.10.0-git6492-linux.tar.gz"

ADDONS_TMP=/tmp/csgo-addons
ADDONS_UPDATE_DIR=/home/steam/csgo-addons

function download_metamod() {
	local MM_DEST="$ADDONS_UPDATE_DIR/metamod"
	mkdir -p "$ADDONS_TMP"
	curl -o "$ADDONS_TMP/metamod.tar.gz" "$METAMOD_URL"
	mkdir -p "$MM_DEST"
	tar xf "$ADDONS_TMP/metamod.tar.gz" -C "$MM_DEST"
}

function update_metamod() {
	# overwrite everything
	echo "Updating metamod..."
	rsync -ai "$ADDONS_UPDATE_DIR/metamod/" "$CSGO_DIR/csgo/"
}

SM_DEST="$ADDONS_UPDATE_DIR/sourcemod"
SM_ADDON_DIR="$ADDONS_UPDATE_DIR/sourcemod/addons/sourcemod"
SM_CFG_DIRS=("cfg" "addons/sourcemod/configs")
SM_CFG_DIRS_COPY=("addons/sourcemod/configs/geoip" 
	"addons/sourcemod/configs/sql-init-scripts")

function download_sourcemod() {
	mkdir -p "$ADDONS_TMP"
	curl -o "$ADDONS_TMP/sourcemod.tar.gz" "$SOURCEMOD_URL"
	mkdir -p "$SM_DEST"
	tar xf "$ADDONS_TMP/sourcemod.tar.gz" -C "$SM_DEST"
	# rename sourcemod config dirs to "$dir.orig"
	for dir in "${SM_CFG_DIRS[@]}"; do
		mv "$SM_DEST/$dir" "$SM_DEST/$dir.orig"
	done
	mv "$SM_ADDON_DIR/plugins" "$SM_ADDON_DIR/plugins.orig"
}

