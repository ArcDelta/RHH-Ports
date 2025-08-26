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
GAMEDIR="/$directory/ports/valhalla"
BIG_SCALE=4000
BIG_DELAY=8
SMALL_SCALE=6000
SMALL_DELAY=16

# CD and set permissions
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Exports
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

# Check if patchlog.txt to skip patching
if [ ! -f "$GAMEDIR/patchlog.txt" ] || [ -f "$GAMEDIR/assets/data.win" ]; then
    if [ -f "$controlfolder/utils/patcher.txt" ]; then
        export PATCHER_FILE="$GAMEDIR/tools/patchscript"
        export PATCHER_GAME="$(basename "${0%.*}")"
        export PATCHER_TIME="5 to 10 minutes"
        export controlfolder
        export DEVICE_ARCH
        source "$controlfolder/utils/patcher.txt"
        $ESUDO kill -9 $(pidof gptokeyb)
    else
        echo "This port requires the latest version of PortMaster."
    fi
fi

# Post patcher setup
export LD_LIBRARY_PATH="$GAMEDIR/lib:$LD_LIBRARY_PATH"

# Apply mouse scaling according to screen size
if [ $DISPLAY_WIDTH -gt 720 ]; then
    sed -i "s/^mouse_scale *= *[0-9]\+/mouse_scale = $BIG_SCALE/" "$GAMEDIR/pcl.gptk"
    sed -i "s/^mouse_delay *= *[0-9]\+/mouse_delay = $BIG_DELAY/" "$GAMEDIR/pcl.gptk"
else
    sed -i "s/^mouse_scale *= *[0-9]\+/mouse_scale = $SMALL_SCALE/" "$GAMEDIR/pcl.gptk"
    sed -i "s/^mouse_delay *= *[0-9]\+/mouse_delay = $SMALL_DELAY/" "$GAMEDIR/pcl.gptk"
fi

# Assign gptokeyb and load the game
$GPTOKEYB "gmloadernext.aarch64" -c "valhalla.gptk" &
pm_platform_helper "$GAMEDIR/gmloadernext.aarch64" > /dev/null
./gmloadernext.aarch64 -c gmloader.json

# Cleanup
pm_finish