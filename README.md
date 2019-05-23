# Aseprite-Tag-to-Strip-Script
This script exports the tags of the active Aseprite sprite and exports as a horizontal png strip. The file is labeled with the proper suffix to make import into Game Maker projects much simpler.

This (currently) will export all tags at once.
The putting a name in the directory section does nothing. The sprite suffix is where you include the "base" sprite name.

Resulting Name Format:
{suffix}_{tag}_strip{# of frames}.png
