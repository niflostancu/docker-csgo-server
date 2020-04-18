#!/bin/bash
# Downloads / compiles the requested CSGO addons and stores them on the image

set -e
SDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

source "$SDIR/lib/base-addons.sh"

download_metamod
download_sourcemod

ls -l "$ADDONS_UPDATE_DIR"

#source "$SDIR/lib/base-addons.sh"

