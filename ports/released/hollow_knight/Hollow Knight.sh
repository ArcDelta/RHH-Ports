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
GAMEDIR="/$directory/ports/hollow_knight"
BOX64="$GAMEDIR/box64/box64"

# CD and set log
cd $GAMEDIR/data
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Pre-flight checks for X11 and OpenGL
if [ -z "$DISPLAY" ]; then
    echo "Error: Display manager not found. Hollow Knight requires OpenGL and X11 to run."
    exit 1
fi

if ! command -v glxinfo >/dev/null 2>&1; then
    echo "Error: OpenGL not found. Hollow Knight requires OpenGL and X11 to run."
    exit 1
fi

# Find game
if [ -f "$GAMEDIR/data/hollow_knight.x86_64" ]; then
    GAME="$GAMEDIR/data/hollow_knight.x86_64"
else if [ -f "$GAMEDIR/data/Hollow Knight" ]; then
    GAME="$GAMEDIR/data/Hollow Knight"
fi

# Exports
export LD_LIBRARY_PATH="$GAMEDIR/box64/x64:$GAMEDIR/libs.aarch64:$GAMEDIR/data:$LD_LIBRARY_PATH"
export BOX64_LD_LIBRARY_PATH="$GAMEDIR/box64/x64:$GAMEDIR/gamedata:$LD_LIBRARY_PATH"
export XDG_CONFIG_HOME="$GAMEDIR/config" && mkdir -p "$GAMEDIR/config"

# Box64 optimizations
export BOX64_NOBANNER=1
export BOX64_DYNAREC=1
export BOX64_DYNAREC_SAFEFLAGS=1
export BOX64_DYNAREC_FASTROUND=0
export BOX64_BIGBLOCK=1
export BOX64_DYNAREC_BIGBLOCK=1
export BOX64_DYNAREC_CALLRET=0
export BOX64_VSYNC=0
export LIBGL_NOERROR=1
export MESA_NO_ERROR=1

# Display loading splash
[ "$CFW_NAME" == "muOS" ] && $ESUDO "$GAMEDIR/tools/splash" "$GAMEDIR/splash.png" 1 
$ESUDO "$GAMEDIR/tools/splash" "$GAMEDIR/splash.png" 30000 &

# Use x11 for game but not for splash
export SDL_VIDEODRIVER="x11"

# Run it
$GPTOKEYB $GAME -c "$GAMEDIR/hollowknight.gptk" & 
pm_platform_helper $GAME > /dev/null
$BOX64 $GAME -force-opengl -screen-fullscreen 1 -screen-width $DISPLAY_WIDTH -screen-height $DISPLAY_HEIGHT

#Clean up after ourselves
pm_finish