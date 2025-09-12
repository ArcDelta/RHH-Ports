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
else
    # Extract the OpenGL version number (e.g., "4.6" or "3.3")
    version=$(glxinfo | grep -oP 'OpenGL version string: \K[0-9]+\.[0-9]+' | head -n 1)

    # Split into major and minor version
    major=${version%%.*}
    minor=${version#*.}

    # Check if it's at least 3.3
    if [ "$major" -lt 3 ] || { [ "$major" -eq 3 ] && [ "$minor" -lt 3 ]; }; then
        # Spoof the GL version so we can launch the game
        export MESA_GL_VERSION_OVERRIDE=3.3
        export MESA_GLSL_VERSION_OVERRIDE=330
        export MESA_NO_ASYNC_COMPILE=1
    fi
    
    # Warn the user in log
    echo "[WARNING] Overriding GL version to run the game; this may have unintended side effects or performance issues!"
fi

# Find game
if [ -f "$GAMEDIR/data/hollow_knight.x86_64" ]; then
    GAME="$GAMEDIR/data/hollow_knight.x86_64"

elif [ -f "$GAMEDIR/data/Hollow Knight" ]; then
    GAME="$GAMEDIR/data/Hollow Knight"

    # Rename the accompanying Unity data folder, if it exists
    if [ -d "$GAMEDIR/data/Hollow Knight_Data" ]; then
        mv "$GAMEDIR/data/Hollow Knight_Data" \
           "$GAMEDIR/data/Hollow_Knight_Data"
    fi
fi

# Exports
export LD_LIBRARY_PATH="$GAMEDIR/box64/x64:$GAMEDIR/libs.aarch64:$GAMEDIR/data:$LD_LIBRARY_PATH"
export BOX64_LD_LIBRARY_PATH="$GAMEDIR/box64/x64:$GAMEDIR/gamedata:$LD_LIBRARY_PATH"
export XDG_CONFIG_HOME="$GAMEDIR/config" && mkdir -p "$GAMEDIR/config"

# Box64 optimizations -- see https://github.com/ptitSeb/box64/blob/main/docs/USAGE.md
export BOX64_NOBANNER=1                # Hide Box64 startup banner (cleaner logs)
export BOX64_DYNAREC=1                 # Enable the JIT dynarec for x86_64 to ARM
export BOX64_DYNAREC_SAFEFLAGS=0       # Skip extra flag-preservation checks for speed
export BOX64_DYNAREC_FASTROUND=0       # Use precise IEEE rounding (safer than fast mode)
export BOX64_DYNAREC_CALLRET=2         # Disable CALL/RET optimizations (more compatible)
export BOX64_DYNAREC_DIRTY=1           # https://github.com/ptitSeb/box64/blob/main/docs/USAGE.md#box64_dynarec_dirty
export BOX64_DYNAREC_BIGBLOCK=3        # Merge more instructions per block (moderate aggressiveness)
export BOX64_DYNAREC_FORWARD=1024      # Scan up to X bytes ahead to extend blocks -- weaker CPUs may want this value lowered or disabled entirely
export BOX64_RDTSC_1GHZ=1              # Emulate RDTSC at 1 GHz for predictable timing
export BOX64_VSYNC=0                   # Allow Unity engine to control vsync

# OpenGL/Mesa error suppression (minor perf gain)
export LIBGL_NOERROR=1                 # Don’t check GL errors
export MESA_NO_ERROR=1                 # Don’t check Mesa GL errors

# Display loading splash
[ "$CFW_NAME" == "muOS" ] && $ESUDO "$GAMEDIR/tools/splash" "$GAMEDIR/splash.png" 1 
$ESUDO "$GAMEDIR/tools/splash" "$GAMEDIR/splash.png" 30000 &

# Use x11 for game but not for splash
export SDL_VIDEODRIVER="x11"

# Run it
$GPTOKEYB $GAME xbox360 & 

# Unity has an older SDL with other GUID syntax, and only configured controllers are ignored,
# so here we create a bare minimum config and ignore the system controller
export SDL_GAMECONTROLLERCONFIG="03000000202000000130000001000000,,"
export SDL_GAMECONTROLLER_IGNORE_DEVICES=0x2020/0x3001

pm_platform_helper $GAME > /dev/null
$BOX64 $GAME -force-opengl -screen-fullscreen 1 -screen-width $DISPLAY_WIDTH -screen-height $DISPLAY_HEIGHT

#Clean up after ourselves
pm_finish