#!/bin/bash

XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}

# Detect PortMaster control folder
if [ -d "/opt/system/Tools/PortMaster/" ]; then
    controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
    controlfolder="/opt/tools/PortMaster"
elif [ -d "$XDG_DATA_HOME/PortMaster/" ]; then
    controlfolder="$XDG_DATA_HOME/PortMaster"
else
    controlfolder="/roms/ports/PortMaster"
fi

source "$controlfolder/control.txt"
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

# Paths and constants
GAMEDIR="/$directory/ports/smb1r"
BOX64="$GAMEDIR/box64/box64"
NES_DIR="/$directory/nes"
CONFDIR="$GAMEDIR/config"
TARGET_ROM="$CONFDIR/SMB1R/baserom.nes"
VALID_MD5="f94bb9bb55f325d9af8a0fff80b9376d"

# Logging and permissions
cd "$GAMEDIR"
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1
$ESUDO chmod +rwx "$GAMEDIR/SMB1R.x86_64"

# Environment exports
export XDG_DATA_HOME="$CONFDIR"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export GODOT_SILENCE_ROOT_WARNING=1

# --- ROM detection & validation ---
find_and_copy_rom() {
    mkdir -p "$(dirname "$TARGET_ROM")"
    local search_dirs=("$GAMEDIR" "$NES_DIR")
    local found=false

    for dir in "${search_dirs[@]}"; do
        echo "Searching in $dir..."

        # 1. Check .nes files
        for rom in "$dir"/*.nes; do
            [ -e "$rom" ] || continue
            md5=$(md5sum "$rom" | awk '{print $1}')
            if [[ "$md5" == "$VALID_MD5" ]]; then
                echo "Valid ROM found: $rom"
                cp "$rom" "$TARGET_ROM"
                found=true
                break 2
            fi
        done

        # 2. Check .nes files inside zip archives
        for zip in "$dir"/*.zip; do
            [ -e "$zip" ] || continue
            while IFS= read -r nes_file; do
                tmpfile=$(mktemp)
                unzip -p "$zip" "$nes_file" > "$tmpfile" 2>/dev/null
                md5=$(md5sum "$tmpfile" | awk '{print $1}')
                if [[ "$md5" == "$VALID_MD5" ]]; then
                    echo "Valid ROM found inside zip: $zip -> $nes_file"
                    cp "$tmpfile" "$TARGET_ROM"
                    found=true
                    rm -f "$tmpfile"
                    break 3
                fi
                rm -f "$tmpfile"
            done < <(unzip -Z1 "$zip" | grep -i '\.nes$')
        done
    done

    if ! $found; then
        echo "No valid baserom.nes found in $GAMEDIR or $NES_DIR!"
        exit 1
    fi
}

# Run ROM search
[ ! -f "$TARGET_ROM" ] && find_and_copy_rom

# --- Launch the game ---
$GPTOKEYB "SMB1R.x86_64" -c "mario.gptk" &
pm_platform_helper "$GAMEDIR/SMB1R.x86_64" >/dev/null
$BOX64 ./SMB1R.x86_64

# Cleanup
pm_finish
