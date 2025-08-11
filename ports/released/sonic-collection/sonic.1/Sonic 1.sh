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
GAMEDIR="/$directory/ports/sonic1"

# CD and set permissions
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1
$ESUDO chmod +x -R $GAMEDIR/*

# Exports
export LD_LIBRARY_PATH="/usr/lib:$GAMEDIR/libs":$LD_LIBRARY_PATH
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

# Setup gl4es environment
if [ -f "${controlfolder}/libgl_${CFW_NAME}.txt" ]; then 
  source "${controlfolder}/libgl_${CFW_NAME}.txt"
else
  source "${controlfolder}/libgl_default.txt"
fi

get_res() {
    # RSDK default resolution
    BASE_WIDTH=424
    BASE_HEIGHT=240

    # Calculate integer scale factor for height
    SCALE=$(( DISPLAY_HEIGHT / BASE_HEIGHT ))

    # Calculate scaled width
    SCALED_WIDTH=$(( BASE_WIDTH * SCALE ))

    # If scaled width is too big for screen, reduce until it fits
    while [ $SCALED_WIDTH -gt $DISPLAY_WIDTH ]; do
        BASE_WIDTH=$(( BASE_WIDTH - 1 ))
        SCALED_WIDTH=$(( BASE_WIDTH * SCALE ))
    done

    # Final internal width is base width after adjustment
    WIDTH=$BASE_WIDTH

    # Update settings.ini
    if grep -q "^ScreenWidth=[0-9]\+" "$GAMEDIR/settings.ini"; then
        sed -i "s/^ScreenWidth=[0-9]\+/ScreenWidth=$WIDTH/" "$GAMEDIR/settings.ini"
    else
        echo "Possible invalid or missing settings.ini!"
    fi
}

# Adjust game resolution
get_res

# Check if running Sonic Forever
result=$(grep "^SonicForeverMod=true" "$GAMEDIR/mods/modconfig.ini")

if [ -n "$result" ]; then
    GAME=sonicforever
else
    GAME=sonic2013
fi

# Run the game
$GPTOKEYB $GAME -c "sonic.gptk" &
pm_platform_helper "$GAME"
./$GAME

# Cleanup
pm_finish
