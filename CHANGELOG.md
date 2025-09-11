# RHH-Ports Changelog

This changelog provides a brief summary of ports that have been updated by month. If multiple updates occur in a single month, the latest is logged here.

## Released Ports - September 2025

#### Hollow Knight
Add port and update to resolve input issues on Retroid Pocket 5 family of systems.

## Released Ports - August 2025

#### Isles of Sea and Sky
Update for compatibility with v2.x "The Mysterious Update". Use UTMT-CLI to facilitate required gml edits to allow small-arm performance gains, and externalize textures. Xdelta no longer required, reducing maintenance overhead.

#### Dead Cells and Tenjutsu
Add new port. Dead Cells requires a lot of RAM but can still run on other Rocknix systems by spoofing the GL version to 3.3. The same was done for ready to run port Tenjustu 48H.

#### Sonic Collection
Sonic 1, 2, CD, and Mania were updated to use integer scaling for pixWidth, calculated by using a base internal resolution. This will hopefully eliminate render issues on a variety of display resolutions.

#### Spine Lasher
Added a new port for the Spine Lasher demo.

#### Undertale Red & Yellow
Update for compatibility with latest version v2.1.2 and allow using GOG Undertale base data.

#### Doom Engines
Add library `libmodplug.so.1` and add Ashes mod example files.

#### Victory Heat Rally
Use UTMT-CLI to facilitate required gml edits and reduce maintenance overhead. Use gmloader-next with video support to restore Playtonic intro splash. Externalize textures.

#### Va11-HALL-A
Update port to run as 64-bit by updating bytecode version, allowing port to run on devices lacking armhf drivers like TrimUI.

#### Yeo Trilogy
Friends of Ringo Ishikawa, Fading Afternoon, and Arrest of a Stone Buddha now use UTMT-CLI to facilitate required gml edits. This reduces maintenance overhead and allows a greater variety of data sources to be used.

#### Descent I/II
Fix broken port by enforcing x11 driver when using mainline firmwares.

## Unreleased Ports - August 2025

#### Picayune Dreams
Clarify stall reason in readme file.

#### Sonic Unleashed Recomp
Clarify stall reason in readme file.