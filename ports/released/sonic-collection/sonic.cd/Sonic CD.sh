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
get_controls
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

# Set variables
GAMEDIR="/$directory/ports/soniccd"

# CD and set permissions
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1
$ESUDO chmod +x -R $GAMEDIR/*

# Exports
export LD_LIBRARY_PATH="$GAMEDIR/libs":$LD_LIBRARY_PATH
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

# Setup gl4es environment
if [ -f "${controlfolder}/libgl_${CFW_NAME}.txt" ]; then 
  source "${controlfolder}/libgl_${CFW_NAME}.txt"
else
  source "${controlfolder}/libgl_default.txt"
fi

# Calculate aspect ratio with full precision
ASPECT=$(awk -v w="$DISPLAY_WIDTH" -v h="$DISPLAY_HEIGHT" 'BEGIN { printf "%.6f", w / h }')

# Calculate pixWidth
PIXWIDTH=$(awk -v h="240" -v a="$ASPECT" 'BEGIN { printf "%d", h * a }')

if grep -q "^ScreenWidth=[0-9]\+" "$GAMEDIR/settings.ini"; then
    sed -i "s/^ScreenWidth=[0-9]\+/ScreenWidth=$PIXWIDTH/" "$GAMEDIR/settings.ini"
else
    echo "Possible invalid or missing settings.ini!"
fi

# Run the game
$GPTOKEYB "soniccd" -c "sonic.gptk" &
pm_platform_helper "soniccd"
./soniccd

# Cleanup
pm_finish