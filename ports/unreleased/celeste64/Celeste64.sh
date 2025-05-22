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
GAMEDIR="/$directory/ports/celeste64"

# Setup logging
cd "$GAMEDIR"
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Setup savedir
bind_directories ~/.local/share/Celeste64 "$GAMEDIR/savedata"

# Permissions
chmod +x Celeste64

# First run
if [ -f "Content.zip" ]; then
    if unzip "Content.zip"; then
        rm -f "Content.zip"
    fi
fi

# Run
$GPTOKEYB "Celeste64" xbox360 &
pm_platform_helper "$GAMEDIR/Celeste64" > /dev/null
./Celeste64

# Cleanup
pm_finish