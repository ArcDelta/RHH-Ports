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

$ESUDO chmod 666 /dev/tty1
$ESUDO chmod 666 /dev/uinput

GAMEDIR="/$directory/ports/openmw"
mkdir -p "$GAMEDIR"

cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export LD_LIBRARY_PATH="${GAMEDIR}/libs:${LD_LIBRARY_PATH}"
export XDG_DATA_HOME="$GAMEDIR"
export XDG_CONFIG_HOME="$GAMEDIR"
export OPENMW_DECOMPRESS_TEXTURES=1
#export TEXTINPUTPRESET="Eddie"
#export TEXTINPUTINTERACTIVE="Y"

$GPTOKEYB2 "morrowind" -c "openmw.ini" &
pm_platform_helper "$GAMEDIR/morrowind" > /dev/null
./morrowind

pm_finish