#!/bin/bash

XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}

if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
elif [ -d "$XDG_DATA_HOME/PortMaster/" ]; then
  controlfolder="$XDG_DATA_HOME/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

source $controlfolder/control.txt
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

# Variables
GAMEDIR="/$directory/ports/deadcells"
GAME="$GAMEDIR/gamedata/deadcells"
BOX64="$GAMEDIR/box64/box64"

# CD and set log
cd $GAMEDIR/gamedata
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

gl_test() {
    # Extract the OpenGL version number (e.g., "4.6" or "3.3")
    version=$(glxinfo | grep -oP 'OpenGL version string: \K[0-9]+\.[0-9]+' | head -n 1)

    # Split into major and minor version
    major=${version%%.*}
    minor=${version#*.}

    # Check if it's at least 3.3
    if [ "$major" -lt 3 ] || { [ "$major" -eq 3 ] && [ "$minor" -lt 3 ]; }; then
        echo "Hashlink requires minimum OpenGL 3.3, and your version ($version) is too old."
        exit 1
    fi
}

# Run the GL test
gl_test

# Exports
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export LD_LIBRARY_PATH="$GAMEDIR/box64/x64:$GAMEDIR/libs.aarch64:$GAMEDIR/gamedata:$LD_LIBRARY_PATH"
export BOX64_LD_LIBRARY_PATH="$GAMEDIR/box64/x64:$GAMEDIR/gamedata:$LD_LIBRARY_PATH"
export SDL_VIDEODRIVER="x11"
export BOX64_NOBANNER=1
export BOX64_DYNAREC=1

# Run it
$GPTOKEYB "deadcells" xbox360 & 
pm_platform_helper "$GAMEDIR/deadcells" > /dev/null
"$BOX64" "$GAME"

#Clean up after ourselves
pm_finish