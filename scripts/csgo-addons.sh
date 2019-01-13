#!/bin/bash
# Downloads the CSGO addons for installation

ADDONS=(
	"https://mms.alliedmods.net/mmsdrop/1.10/mmsource-1.10.7-git968-linux.tar.gz"
	"https://sm.alliedmods.net/smdrop/1.9/sourcemod-1.9.0-git6273-linux.tar.gz"
)

set -e

mkdir -p /home/steam/csgo-addons
mkdir -p /tmp/addon-archives
cd /home/steam/csgo-addons

for url in "${ADDONS[@]}"; do
	name=${url##*/}
	curl -o "/tmp/addon-archives/$name" "$url"
	tar xf "/tmp/addon-archives/$name"
done

rm -rf /tmp/addon-archives

