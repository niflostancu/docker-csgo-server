#!/bin/bash
# Functions for SourceMod plugins management

# note: uses variables set in base-addons.sh

SM_PLUGINS_DIR=$CSGO_DIR/csgo/addons/sourcemod/plugins

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
			"$ADDONS_UPDATE_DIR/sourcemod/$dir.orig/" "$CSGO_DIR/csgo/$dir/"
	done
	# update plugins, but keep their disable states
	echo "Updating sourcemod plugins..."
	(
		SRC="$SM_ADDON_DIR/plugins.orig"
		cd "$SRC"
		PLUGINS=(*)
		DISABLED_PLUGINS=()
		if [[ -d "disabled" ]]; then
			cd "disabled"
			DISABLED_PLUGINS=(*)
		fi
		mkdir -p "$SM_PLUGINS_DIR/disabled/"
		for plug in "${PLUGINS[@]}"; do
			if [[ "$plug" == "disabled" ]]; then continue; fi
			plug_dst="$plug"  # default to enabled
			if [[ -e "$SM_PLUGINS_DIR/disabled/$plug" ]]; then
				plug_dst="disabled/$plug"
			fi
			# remove old files (in case of directories)
			rm -rf "$SM_PLUGINS_DIR/$plug"
			rm -rf "$SM_PLUGINS_DIR/disabled/$plug"
			echo "plugin $plug to $plug_dst"
			cp -rf "$SRC/$plug" "$SM_PLUGINS_DIR/$plug_dst"
		done
		# update plugins that are disabled by default
		for plug in "${DISABLED_PLUGINS[@]}"; do
			if [[ "$plug" == "disabled" ]]; then continue; fi
			plug_dst="disabled/$plug"  # default to disabled
			if [[ -e "$SM_PLUGINS_DIR/$plug" ]]; then
				plug_dst="$plug"
			fi
			# cleanup, just in case
			rm -rf "$SM_PLUGINS_DIR/$plug"
			rm -rf "$SM_PLUGINS_DIR/disabled/$plug"
			echo "plugin $plug to $plug_dst"
			cp -rf "$SRC/disabled/$plug" "$SM_PLUGINS_DIR/$plug_dst"
		done
	)
}

# utility function used for source plugin compilation
# automatically installs the compiled plugin
function sm_compile_install()
{
	for sourcefile in "$@"; do
		srcfile=$(basename "$sourcefile")
		sourcefile="$(realpath "$sourcefile")"
		smxfile="${srcfile%.sp}.smx"
		smxdest="$SM_ADDON_DIR/plugins.orig/$smxfile"
		echo -e "\nCompiling plugin $srcfile..."
		( cd "$SM_ADDON_DIR/scripting/"; ./spcomp64 "$sourcefile" -o"$smxdest" )
		rm -f "$SM_ADDON_DIR/plugins/disabled/$smxfile"
	done
}

# Enables the specified sourcemod plugin(s)
function sm_enable()
{
	for plug in "$@"; do
		if [[ -e "$SM_PLUGINS_DIR/disabled/$plug" ]]; then
			mv "$SM_PLUGINS_DIR/disabled/$plug" "$SM_PLUGINS_DIR/$plug"
		fi
	done
}

# Disables the specified sourcemod plugin(s)
function sm_enable()
{
	for plug in "$@"; do
		if [[ -e "$SM_PLUGINS_DIR/$plug" ]]; then
			mv "$SM_PLUGINS_DIR/$plug" "$SM_PLUGINS_DIR/disabled/$plug"
		fi
	done
}

