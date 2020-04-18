#!/bin/bash
# Installs MetaMod and SourceMod into the ADDONS_UPDATE_DIR

set -e
SDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

source "$SDIR/lib/base-addons.sh"
source "$SDIR/lib/sourcemod.sh"

download_metamod
download_sourcemod

