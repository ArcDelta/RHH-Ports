## Installation
Download the latest [Linux.zip release](https://github.com/JHDev2006/Super-Mario-Bros.-Remastered-Public/releases/tag/1.0.1) and unzip contents to the `ports/smb1r` folder.

You must provide a copy of Super Mario Bros. for the NES. The launchscript will search for the rom in the port folder and in your `roms/nes` folder.

## Usage
Gamepad controls and modernization options can be set in the settings menu.

Mods can be found at [Gamebanana](https://gamebanana.com/mods/games/22798) and can be installed in the config folders at `smb1r/config/SMB1R`.

Custom levels are hosted with nonprofit [Level Share Square](https://levelsharesquare.com/SMBR/levels) and can be installed the same way or can be downloaded directly within SMB1R with an internet connection.

## Notes
This port requires x11 or wayland since Godot 4.5 requires it. Although a 4.5 export template for arm64 exists, the game still relies on `libgodotgif.linux.template_release.x86_64.so` and `libdiscord_game_sdk.so` which do not have readily available arm64 builds.

## Thanks
JHDev2006 and contributors -- The remaster  
ptitSeb -- Box64  