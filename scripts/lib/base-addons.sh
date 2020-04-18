#!/bin/bash
# Functions for HL addon management

# Update the URLs
METAMOD_URL="https://mms.alliedmods.net/mmsdrop/1.10/mmsource-1.10.7-git971-linux.tar.gz"
SOURCEMOD_URL="https://sm.alliedmods.net/smdrop/1.10/sourcemod-1.10.0-git6482-linux.tar.gz"

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

SM_CFG_DIRS=("cfg" "addons/sourcemod/configs")
SM_CFG_PLUGINS=("addons/sourcemod/plugins")
SM_CFG_DIRS_COPY=("addons/sourcemod/configs/geoip" 
	"addons/sourcemod/configs/sql-init-scripts")

function download_sourcemod() {
	local SM_DEST="$ADDONS_UPDATE_DIR/sourcemod"
	mkdir -p "$ADDONS_TMP"
	curl -o "$ADDONS_TMP/sourcemod.tar.gz" "$SOURCEMOD_URL"
	mkdir -p "$SM_DEST"
	tar xf "$ADDONS_TMP/sourcemod.tar.gz" -C "$SM_DEST"
	# rename sourcemod config dirs to "$dir.orig"
	for dir in "${SM_CFG_DIRS[@]}"; do
		mv "$SM_DEST/$dir" "$SM_DEST/$dir.orig"
	done
	for dir in "${SM_CFG_PLUGINS[@]}"; do
		mv "$SM_DEST/$dir" "$SM_DEST/$dir.orig"
	done
}

function update_sourcemod() {
	# overwrite everything except dirs marked '*.orig'
	echo "Updating sourcemod base files..."
	rsync -ai --exclude="*.orig" \
		"$ADDONS_UPDATE_DIR/sourcemod/" "$CSGO_DIR/csgo/"
	# overwrite the exceptions
	local INCS=()
	echo "Updating sourcemod data files..."
	for inc in "${SM_CFG_DIRS_COPY[@]}"; do INCS+=(--include="$inc"); done
	rsync -ai "${INCS[@]}" --exclude="*" \
		"$ADDONS_UPDATE_DIR/sourcemod/" "$CSGO_DIR/csgo/"
	# copy configs, but in non-overwriting mode
	echo "Updating sourcemod configs (non-overwriting)..."
	for dir in "${SM_CFG_DIRS[@]}"; do
		mkdir -p "$CSGO_DIR/csgo/$dir"
		rsync -ai --ignore-existing \
			"$ADDONS_UPDATE_DIR/sourcemod/$dir.orig" "$CSGO_DIR/csgo/$dir"
	done
	# update plugins, but keep their disable states
	echo "Updating sourcemod plugins..."
	for dir in "${SM_CFG_PLUGINS[@]}"; do
		(
			SRC="$ADDONS_UPDATE_DIR/sourcemod/$dir.orig"
			DST="$CSGO_DIR/csgo/sourcemod/$dir"
			cd "$SRC"
			PLUGINS=(*)
			DISABLED_PLUGINS=()
			if [[ -d "disabled" ]]; then
				cd "disabled"
				DISABLED_PLUGINS=(*)
			fi
			mkdir -p "$DST/disabled/"
			for plug in "${PLUGINS[@]}"; do
				if [[ "$plug" == "disabled" ]]; then continue; fi
				plug_dst="$plug"  # default to enabled
				if [[ -e "$DST/disabled/$plug" ]]; then
					plug_dst="disabled/$plug"
				fi
				# remove old files (in case of directories)
				rm -rf "$DST/$plug"
				rm -rf "$DST/disabled/$plug"
				echo "plugin $plug to $plug_dst"
				cp -rf "$SRC/$plug" "$DST/$plug_dst"
			done
			# update plugins that are disabled by default
			for plug in "${DISABLED_PLUGINS[@]}"; do
				if [[ "$plug" == "disabled" ]]; then continue; fi
				plug_dst="disabled/$plug"  # default to disabled
				if [[ -e "$DST/$plug" ]]; then
					plug_dst="$plug"
				fi
				# cleanup, just in case
				rm -rf "$DST/$plug"
				rm -rf "$DST/disabled/$plug"
				echo "plugin $plug to $plug_dst"
				cp -rf "$SRC/disabled/$plug" "$DST/$plug_dst"
			done
		)
	done
}

