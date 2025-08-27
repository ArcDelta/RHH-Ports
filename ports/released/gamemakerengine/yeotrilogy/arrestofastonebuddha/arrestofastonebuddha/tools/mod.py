#!/usr/bin/env python3
import os
import sys

def replace_screen_init(gml_dir):
    """Replace gml_GlobalScript_screen_init.gml with the working screen_init function"""
    filename = "gml_Script_screen_init.gml"
    file_path = os.path.join(gml_dir, filename)

    new_code = [
        "application_surface_draw_enable(true);",
        "screen_x = 0;",
        "screen_y = 0;",
        "screen_w = 320;",
        "screen_h = 180;",
        "checking_room = -1;",
        "dis_width = display_get_width();",
        "dis_height = display_get_height();",
        "fs_width = dis_width / screen_w;",
        "fs_height = dis_height / screen_h;",
        "global.scale_ini = floor(fs_width);",
        "screen_scale = global.scale_ini;",
        "",
        "if (fs_width <= fs_height)",
        "{",
        "    global.fs_scale = fs_width;",
        "    fs_x = 0;",
        "    fs_y = floor((dis_height - (screen_h * global.fs_scale)) / 2);",
        "}",
        "else",
        "{",
        "    global.fs_scale = fs_height;",
        "    fs_x = floor((dis_width - (screen_w * global.fs_scale)) / 2);",
        "    fs_y = 0;",
        "}",
        "",
        "surface_resize(application_surface, screen_w, screen_h);",
        "screen = 1;",
        "",
        "if (screen == -1)",
        "{",
        "    window_set_size(screen_w * screen_scale, screen_h * screen_scale);",
        "    window_center();",
        "    screen_scale = 1;",
        "    instance_destroy();",
        "}",
        "",
        "do",
        "{",
        "    if (checking_room == -1)",
        "        checking_room = room_first;",
        "    else",
        "        checking_room = room_next(checking_room);",
        "",
        "    room_set_background_color(checking_room, c_black, false);",
        "    room_set_width(checking_room, screen_w);",
        "",
        "    if (checking_room == 6)",
        "        room_set_width(checking_room, 1000);",
        "",
        "    room_set_height(checking_room, screen_h);",
        "    room_set_view_enabled(checking_room, true);",
        "    room_set_view(checking_room, 0, 1, 0, 0, screen_w, screen_h, 0, 0, screen_w * global.fs_scale, screen_h * global.fs_scale, 100, 32, -1, -1, -1);",
        "}",
        "until (checking_room == room_last);",
        "",
        "window_set_fullscreen(true);",
        "window_center();",
    ]

    with open(file_path, "w") as f:
        f.writelines(line + "\n" for line in new_code)

def modify_options_create(gml_dir):
    """Prepend screen_init(); to gml_Object_obj_options_21_Create_0.gml"""
    filename = "gml_Object_obj_options_21_Create_0.gml"
    file_path = os.path.join(gml_dir, filename)

    with open(file_path, "r") as f:
        existing_code = f.readlines()
    existing_code = [line.rstrip("\n") for line in existing_code]
    new_code = ["screen_init();"] + existing_code

    with open(file_path, "w") as f:
        f.writelines(line + "\n" for line in new_code)

def main(gml_dir):
    replace_screen_init(gml_dir)
    modify_options_create(gml_dir)

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: mod.py <gml_directory>")
        sys.exit(1)
    main(sys.argv[1])