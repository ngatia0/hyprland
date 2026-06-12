#!/bin/bash

# constants
BASE_URL="https://wallhaven.cc/api/v1/search?"
QUERY_PARAMS="bleach"
WALLPAPER_DIR="${HOME}/Pictures/wallpapers/"
HYPRPAPER_CONF_FILE="$HOME/.config/hypr/hyprpaper.conf"
TMP_FILE="${WALLPAPER_DIR}tmp.txt"
MIN_RES="2560x2048"
PERMITTED_RATIO="16x9,16x10"
MAX_IMAGES=150        # images to fetch per session
MAX_PAGES=200
DEFAULT_CATEGORY="anime"
DEFAULT_PURITY="sfw"
API_KEY="HjRnWRFfG87QKPAPJsVOsn1Mv8UO81zj"
MONITOR_NAME="eDP-1"
DO_DOWNLOAD=0
DO_RANDOM=0
SET_FILE=""
CATEGORIES_VAL=0
PURITY_VAL=0

if [[ $# -eq 0 ]]; then
	echo "+-------------------------------------------------------------+"
	echo -e "|    \e[38;5;196m  _                      _                           \e[0m    |"
	echo -e "|    \e[38;5;202m | |__  _   _ _ __  _ __| |__   __ ___   _____ _ __  \e[0m    |"
	echo -e "|    \e[38;5;208m | '_ \| | | | '_ \| '__| '_ \ / _\` \ \ / / _ \ '_ \ \e[0m    |"
	echo -e "|    \e[38;5;214m | | | | |_| | |_) | |  | | | | (_| |\ V /  __/ | | |\e[0m    |"
	echo -e "|    \e[38;5;220m |_| |_|\__, | .__/|_|  |_| |_|\__,_| \_/ \___|_| |_|\e[0m    |"
	echo -e "|    \e[38;5;226m        |___/|_|                                     \e[0m    |"
	echo "+-------------------------------------------------------------+"
	echo -e "\n\nOptions:\n"
	echo "-r: Set a random wallpaper from the local directory."
	echo "-d: Fetch and download wallpapers from Wallhaven."
	echo "-c CATEGORY: Override category (e.g., \"general, anime\")."
	echo "-p PURITY: Override purity (e.g., \"sfw, sketchy\")."
	echo "-q QUERY: Search query."
	echo "-s FILE_PATH: Set a specific wallpaper."
	exit 1
fi

doesFileExist() {
	if ! [[ -f $1 ]]; then
		echo "$1 File not found"
		exit 1
	fi
}

getImgUrl() {
	echo "https://w.wallhaven.cc/full/$(echo $1 | cut -c1-2)/wallhaven-$1.$2"
}

setConfigs() {
	[[ -n "$2" ]] && QUERY_PARAMS+="&$1=$2"
}

setQuery() {
	local PARSED_QUERY=$(echo $1 | awk '{$1=$1; print}' | sed 's/ /%20/g')
	QUERY_PARAMS+="&q=$PARSED_QUERY"
}

applyModifiers() {
	local PARAM_TYPE=$1
	local INPUT_STRING=$2
	local CAT=0
	local PUR=0

	[[ -z "$INPUT_STRING" ]] && return

	local PARSED=$(echo "$INPUT_STRING" | tr ", " " " | awk '{$1=$1; print}')
	local ARRAY=($PARSED)

	for MODIFIER in "${ARRAY[@]}"; do
		case "$MODIFIER" in
		general)  ((CAT += 100)) ;;
		anime)    ((CAT += 10)) ;;
		people)   ((CAT += 1)) ;;
		sfw)      ((PUR += 100)) ;;
		sketchy)  ((PUR += 10)) ;;
		nsfw)     [[ -n $API_KEY ]] && ((PUR += 1)) || echo "API key not set — cannot access nsfw." ;;
		esac
	done

	if [[ "$PARAM_TYPE" == "category" ]]; then
		CATEGORIES_VAL=$(printf "%03d" $CAT)
		QUERY_PARAMS+="&categories=$CATEGORIES_VAL"
	elif [[ "$PARAM_TYPE" == "purity" ]]; then
		PURITY_VAL=$(printf "%03d" $PUR)
		QUERY_PARAMS+="&purity=$PURITY_VAL"
	fi
}

setWallpaper() {
	doesFileExist $1
	killall hyprpaper 2>/dev/null
	echo -e "preload = $1\nwallpaper = $MONITOR_NAME, $1" > $HYPRPAPER_CONF_FILE
	hyprpaper &
}

setRandomWallpaper() {
	local FILES=$(ls "$WALLPAPER_DIR" | grep -v "tmp.txt")
	if [[ -z "$FILES" ]]; then
		echo "No wallpapers in $WALLPAPER_DIR"
		exit 1
	fi
	local IMG_FILE=$(echo "$FILES" | shuf -n 1)
	setWallpaper "${WALLPAPER_DIR}${IMG_FILE}"
}

getImageUrls() {
	local PAGE_COUNT=1
	> "$TMP_FILE"

	while [[ $(wc -l <"$TMP_FILE") -lt $MAX_IMAGES && $PAGE_COUNT -le $MAX_PAGES ]]; do
		QUERY_PARAMS=$(echo "$QUERY_PARAMS" | sed 's/&page=[0-9]\+//g')
		QUERY_PARAMS+="&page=$PAGE_COUNT"
		curl -s "${BASE_URL}${QUERY_PARAMS#&}" | jq | rg path | sed 's/.*wallhaven-\(.*\)\.\(.*\)".*/\1 \2/g' >> "${TMP_FILE}"
		echo "Page $PAGE_COUNT — total urls: $(wc -l <$TMP_FILE)"
		((PAGE_COUNT++))
	done
}

downloadImages() {
	[[ ! -s "${TMP_FILE}" ]] && echo "Error: image list is empty" && exit 1
	doesFileExist ${TMP_FILE}

	# FIX: Start counter from existing file count + 1
	local EXISTING=$(ls "$WALLPAPER_DIR" | grep -v "tmp.txt" | wc -l)
	local IMG_FILE_COUNTER=$((EXISTING + 1))
	echo ":: Existing wallpapers: $EXISTING — starting from $IMG_FILE_COUNTER"

	local CURRENT_DIRECTORY=$PWD
	cd $WALLPAPER_DIR
	local DOWNLOADED=0

	while IFS= read -r ITEM; do
		if [[ -n "$ITEM" ]]; then
			local FILE_EXTENSION=$(echo $ITEM | awk '{print $2}')
			local OUT_FILE="${IMG_FILE_COUNTER}.${FILE_EXTENSION}"
			echo "Downloading $OUT_FILE..."
			curl -s -o "$OUT_FILE" "$(getImgUrl $ITEM)"
			((IMG_FILE_COUNTER++))
			((DOWNLOADED++))
		fi
	done < "${TMP_FILE}"

	rm "${TMP_FILE}"
	cd $CURRENT_DIRECTORY

	local TOTAL=$(ls "$WALLPAPER_DIR" | grep -v "tmp.txt" | wc -l)
	notify-send "Wallpapers downloaded" "$DOWNLOADED new — $TOTAL total in $WALLPAPER_DIR"
	echo ":: Downloaded $DOWNLOADED new wallpapers. Total: $TOTAL"
}

# Apply hardcoded defaults
applyModifiers "category" "$DEFAULT_CATEGORY"
applyModifiers "purity" "$DEFAULT_PURITY"

# Base configs
setConfigs "apikey" $API_KEY
setConfigs "atleast" $MIN_RES
setConfigs "ratios" $PERMITTED_RATIO
setConfigs "sorting" "random"
setConfigs "seed" "$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 8)"

# Parse flags
while getopts 'rdc:p:q:s:' flag; do
	case "${flag}" in
	r) DO_RANDOM=1 ;;
	d) DO_DOWNLOAD=1 ;;
	c) applyModifiers "category" "${OPTARG}" ;;
	p) applyModifiers "purity" "${OPTARG}" ;;
	q) setQuery "${OPTARG}" ;;
	s) SET_FILE="${OPTARG}" ;;
	*)
		echo "wrong flag"
		exit 1
		;;
	esac
done

# Execute
[[ -n "$SET_FILE" ]] && setWallpaper "$SET_FILE"
[[ $DO_RANDOM -eq 1 ]] && setRandomWallpaper
if [[ $DO_DOWNLOAD -eq 1 ]]; then
	echo "Fetching image urls..."
	getImageUrls
	echo "Downloading images..."
	downloadImages
fi

echo "Query: ${BASE_URL}${QUERY_PARAMS#&}"
