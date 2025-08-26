#!/usr/bin/env python3
import os
import sys

def replace_screen_init(gml_dir):
    """Replace the entire gml_GlobalScript_screen_init.gml file"""
    filename = "gml_GlobalScript_screen_init.gml"
    file_path = os.path.join(gml_dir, filename)

    if not os.path.isfile(file_path):
        print(f"Warning: {filename} not found, creating a new one.")

    new_code = [
        "function screen_init()",
        "{",
        "    application_surface_draw_enable(true);",
        "",
        "    screen_x = 0;",
        "    screen_y = 0;",
        "    screen_w = 240;",
        "    screen_h = 135;",
        "    screen_scale = global.scale_ini;",
        "    checking_room = -1;",
        "    dis_width = display_get_width();",
        "    dis_height = display_get_height();",
        "    global.fs_scale = 1;",
        "    fs_x = 0;",
        "    fs_y = 0;",
        "    surface_resize(application_surface, screen_w, screen_h);",
        "    screen = 1;",
        "    do",
        "    {",
        "        if (checking_room == -1)",
        "            checking_room = room_first;",
        "        else",
        "            checking_room = room_next(checking_room);",
        "        room_set_background_color(checking_room, c_black, false);",
        "        room_set_width(checking_room, (checking_room == 6) ? 1000 : screen_w);",
        "        room_set_height(checking_room, screen_h);",
        "        room_set_view_enabled(checking_room, true);",
        "        room_set_view(checking_room, 0, 1, 0, 0, screen_w, screen_h, 0, 0, dis_width, dis_height, 100, 32, -1, -1, -1);",
        "    }",
        "    until (checking_room == room_last);",
        "",
        "    window_set_fullscreen(true);",
        "}",
    ]

    with open(file_path, "w") as f:
        f.writelines(line + "\n" for line in new_code)
    print(f"{filename} has been replaced successfully.")


def main(gml_dir):
    replace_screen_init(gml_dir)

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: mod.py <gml_directory>")
        sys.exit(1)
    main(sys.argv[1])
