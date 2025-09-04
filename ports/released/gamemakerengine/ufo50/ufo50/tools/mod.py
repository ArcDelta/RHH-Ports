#!/usr/bin/env python3
import os
import sys

def modify_scrInitDisplay(gml_dir):
    """Modify gml_GlobalScript_scrInitDisplay.gml with granular inserts and removes."""
    filename = "gml_GlobalScript_scrInitDisplay.gml"
    file_path = os.path.join(gml_dir, filename)

    if not os.path.isfile(file_path):
        print(f"Warning: {filename} not found, skipping.")
        return

    with open(file_path, "r") as f:
        lines = f.readlines()

    new_lines = []
    in_while_loop = False

    for line in lines:
        stripped = line.strip()
        indent = line[:len(line) - len(line.lstrip())]

        # Replace scaleMax and insert screenRatio, scaleFill
        if stripped == "global.scaleMax = 0;":
            new_lines.append(f"{indent}global.scaleMax = 1;\n")
            new_lines.append(f"{indent}global.screenRatio = global.SCREEN_WIDTH / global.SCREEN_HEIGHT;\n")
            new_lines.append(f"{indent}global.scaleFill = min(display_get_width() / global.SCREEN_WIDTH, display_get_height() / global.SCREEN_HEIGHT);\n")
            continue

        # Skip the while loop
        if stripped.startswith("while ((384 * (global.scaleMax + 1))"):
            in_while_loop = True
            continue
        if in_while_loop:
            if stripped == "}":
                in_while_loop = False
            continue

        # Skip original scaleFill
        if stripped == "global.scaleFill = min(display_get_width() / 384, display_get_height() / 216);":
            continue

        # Replace DEFAULT_SCALE assignment
        if stripped == "global.DEFAULT_SCALE = max(1, global.scaleMax - 2);":
            new_lines.append(f"{indent}global.DEFAULT_SCALE = 1;\n")
            continue

        # Replace scale min capping
        if stripped == "global.scale = min(global.scale, global.scaleMax + 1);":
            new_lines.append(f"{indent}global.scale = 1;\n")
            continue

        # Replace window_set_size
        if stripped == "window_set_size(384 * global.scale, 216 * global.scale);":
            new_lines.append(f"{indent}window_set_size(global.SCREEN_WIDTH * global.scale, global.SCREEN_HEIGHT * global.scale);\n")
            continue
            
        # Insert scrScaleDisplay() right after scrDefinePalette();
        if stripped == "scrDefinePalette();":
            new_lines.append(line)
            new_lines.append(f"{indent}scrScaleDisplay();\n")
            continue

        new_lines.append(line)

    with open(file_path, "w") as f:
        f.writelines(new_lines)

    print(f"Modified {filename} with preserved indentation.")


def modify_scrScaleDisplay(gml_dir):
    """Replace body of gml_GlobalScript_scrScaleDisplay.gml"""
    filename = "gml_GlobalScript_scrScaleDisplay.gml"
    file_path = os.path.join(gml_dir, filename)

    if not os.path.isfile(file_path):
        print(f"Warning: {filename} not found, skipping.")
        return

    new_body = [
        "var _dwidth = window_get_width();",
        "var _dheight = window_get_height();",
        "global.lastWindowWidth = _dwidth;",
        "global.lastWindowHeight = _dheight;",
        "",
        "if (global.dispBordered)",
        "{",
        "    var windowAspectRatio = _dwidth / _dheight;",
        "    var scaleFactor;",
        "",
        "    if (windowAspectRatio > global.screenRatio)",
        "        scaleFactor = _dheight / global.SCREEN_HEIGHT;",
        "    else",
        "        scaleFactor = _dwidth / global.SCREEN_WIDTH;",
        "",
        "    if (global.integerScale)",
        "        scaleFactor = max(floor(scaleFactor), 1);",
        "",
        "    global.scaleScreenWidth = global.SCREEN_WIDTH * scaleFactor;",
        "    global.scaleScreenHeight = global.SCREEN_HEIGHT * scaleFactor;",
        "    global.scaleScreenX = (_dwidth - global.scaleScreenWidth) * 0.5;",
        "    global.scaleScreenY = (_dheight - global.scaleScreenHeight) * 0.5;",
        "}",
        "else",
        "{",
        "    global.scaleScreenWidth = _dwidth;",
        "    global.scaleScreenHeight = _dheight;",
        "    global.scaleScreenX = 0;",
        "    global.scaleScreenY = 0;",
        "}"
    ]

    with open(file_path, "r") as f:
        lines = f.readlines()

    indent = lines[1][:len(lines[1]) - len(lines[1].lstrip())] if len(lines) > 1 else "    "
    new_lines = lines[0:2]  # keep function line and opening brace
    new_lines += [f"{indent}{line}\n" for line in new_body]
    new_lines += lines[-1:]  # closing brace

    with open(file_path, "w") as f:
        f.writelines(new_lines)

    print(f"Modified {filename} with preserved indentation.")


def modify_scrSetDisplayDefaults(gml_dir):
    """Modify gml_GlobalScript_scrSetDisplayDefaults.gml with preserved indentation."""
    filename = "gml_GlobalScript_scrSetDisplayDefaults.gml"
    file_path = os.path.join(gml_dir, filename)

    if not os.path.isfile(file_path):
        print(f"Warning: {filename} not found, skipping.")
        return

    with open(file_path, "r") as f:
        lines = f.readlines()

    new_lines = []
    inserted_defaults = False
    inserted_config = False
    inserted_else = False

    for line in lines:
        stripped = line.strip()
        indent = line[:len(line) - len(line.lstrip())]

        # Insert new defaults
        if stripped == "var _defaultScanlines = 0;":
            new_lines.append(line)
            new_lines.append(f"{indent}_defaultIntegerScale = false;\n")
            new_lines.append(f"{indent}_defaultFilter = true;\n")
            inserted_defaults = True
            continue

        # Insert config reads
        if stripped == "global.fullscreen = scrReadConfig(\"fullscreen\", _defaultFullscreen);":
            new_lines.append(line)
            new_lines.append(f"{indent}global.integerScale = scrReadConfig(\"integerScale\", _defaultIntegerScale);\n")
            new_lines.append(f"{indent}global.dispFilter = scrReadConfig(\"filter\", _defaultFilter);\n")
            inserted_config = True
            continue

        # Remove scale capping
        if stripped.startswith("if (global.scale > (global.scaleMax + 1))"):
            continue
        if stripped == "global.scale = global.scaleMax + 1;":
            continue

        # Replace window_set_size
        if stripped == "window_set_size(384 * global.scale, 216 * global.scale);":
            new_lines.append(f"{indent}window_set_size(global.SCREEN_WIDTH * global.scale, global.SCREEN_HEIGHT * global.scale);\n")
            continue

        # Insert else branch defaults
        if stripped == "global.fullscreen = _defaultFullscreen;":
            new_lines.append(line)
            new_lines.append(f"{indent}global.integerScale = _defaultIntegerScale;\n")
            new_lines.append(f"{indent}global.dispFilter = _defaultFilter;\n")
            inserted_else = True
            continue

        new_lines.append(line)

    with open(file_path, "w") as f:
        f.writelines(new_lines)

    print(f"Modified {filename} with preserved indentation.")

def modify_oScreenHandler_Draw_75(gml_dir):
    """Replace body of gml_Object_oScreenHandler_Draw_75.gml with preserved indentation."""
    filename = "gml_Object_oScreenHandler_Draw_75.gml"
    file_path = os.path.join(gml_dir, filename)

    if not os.path.isfile(file_path):
        print(f"Warning: {filename} not found, skipping.")
        return

    new_body = [
        "var _dwidth, _dheight;",
        "_dwidth = window_get_width();",
        "_dheight = window_get_height();",
        "display_set_gui_size(_dheight * global.screenRatio, _dheight);",
        "if (window_get_fullscreen())",
        "    display_set_gui_maximize(1, 1, 0, 0);",
        "if (do_screen)",
        "{",
        "    if (_dwidth != global.lastWindowWidth || _dheight != global.lastWindowHeight)",
        "        scrScaleDisplay();",
        "    gpu_set_tex_filter(global.dispFilter);",
        "    draw_clear(c_black);",
        "    draw_surface_stretched(application_surface, global.scaleScreenX, global.scaleScreenY, global.scaleScreenWidth, global.scaleScreenHeight);",
        "    gpu_set_tex_filter(false);",
        "}",
        "else",
        "{",
        "    do_screen = true;",
        "}"
    ]

    with open(file_path, "r") as f:
        lines = f.readlines()

    # preserve indentation of opening brace
    indent = lines[1][:len(lines[1]) - len(lines[1].lstrip())] if len(lines) > 1 else "    "
    new_lines = lines[0:2]  # keep function line and opening brace
    new_lines += [f"{indent}{line}\n" for line in new_body]
    new_lines += lines[-1:]  # closing brace

    with open(file_path, "w") as f:
        f.writelines(new_lines)
    print(f"Modified {filename} with preserved indentation.")

def modify_oPauseMenu_Other_14(gml_dir):
    """Modify gml_Object_oPauseMenu_Other_14.gml with granular inserts and preserved indentation."""
    filename = "gml_Object_oPauseMenu_Other_14.gml"
    file_path = os.path.join(gml_dir, filename)

    if not os.path.isfile(file_path):
        print(f"Warning: {filename} not found, skipping.")
        return

    with open(file_path, "r") as f:
        lines = f.readlines()

    new_lines = []
    in_op_display = False
    inserted_vars = False

    for line in lines:
        stripped = line.strip()
        indent = line[:len(line) - len(line.lstrip())]

        # Add vars at the top
        if not inserted_vars and stripped.startswith("SUB_INIT = 0;"):
            new_lines.append(f"{indent}var _dispIndex, choice, _trueScale, _okay;\n")
            new_lines.append(line)
            inserted_vars = True
            continue

        # Replace _dispIndex initialization
        if stripped == "var _dispIndex = 1;":
            new_lines.append(f"{indent}_dispIndex = 0;\n")
            new_lines.append(f"{indent}_dispFilter = global.dispFilter;\n")
            continue

        # Replace OP_DISPLAY case
        if stripped.startswith("case OP_DISPLAY:"):
            new_lines.append(line)
            new_lines.append(f"{indent}    scrSfxLibrary(soundToggle[currentSoundSet]);\n")
            new_lines.append(f"{indent}    global.fullscreen = true;\n")
            new_lines.append(f"{indent}    if (choice == 0) {{\n")
            new_lines.append(f"{indent}        global.dispBordered = true;\n")
            new_lines.append(f"{indent}        global.integerScale = false;\n")
            new_lines.append(f"{indent}    }} else if (choice == 1) {{\n")
            new_lines.append(f"{indent}        global.dispBordered = true;\n")
            new_lines.append(f"{indent}        global.integerScale = true;\n")
            new_lines.append(f"{indent}    }} else if (choice == 2) {{\n")
            new_lines.append(f"{indent}        global.dispBordered = false;\n")
            new_lines.append(f"{indent}        global.integerScale = false;\n")
            new_lines.append(f"{indent}    }}\n")
            new_lines.append(f"{indent}    window_enable_borderless_fullscreen(!global.dispBordered);\n")
            new_lines.append(f"{indent}    window_set_fullscreen(global.fullscreen);\n")
            new_lines.append(f"{indent}    prevFullScreen = window_get_fullscreen();\n")
            new_lines.append(f"{indent}    scrScaleDisplay();\n")
            new_lines.append(f"{indent}    delayLen = delayLenLong;\n")
            new_lines.append(f"{indent}    scrSwitchSub(SUB_DELAY);\n")
            new_lines.append(f"{indent}    break;\n")
            in_op_display = True
            continue
        if in_op_display and stripped == "break;":
            in_op_display = False
            continue
        if in_op_display:
            continue  # skip original OP_DISPLAY body

        # Insert OP_FILTER case before OP_SCALE
        if stripped.startswith("case OP_SCALE:"):
            new_lines.append(f"{indent}case OP_FILTER:\n")
            new_lines.append(f"{indent}    scrSfxLibrary(soundToggle[currentSoundSet]);\n")
            new_lines.append(f"{indent}    global.dispFilter = (choice == 1) ? true : false;\n")
            new_lines.append(f"{indent}    delayLen = delayLenShort;\n")
            new_lines.append(f"{indent}    scrSwitchSub(SUB_DELAY);\n")
            new_lines.append(f"{indent}    break;\n")
            new_lines.append(line)
            continue

        # Replace OP_SCALE body
        if stripped.startswith("global.scale = choice + 1;"):
            new_lines.append(f"{indent}global.scale = 1;\n")
            continue
        if stripped.startswith("var _trueScale = min(global.scale, global.scaleFill);"):
            new_lines.append(f"{indent}_trueScale = min(global.scale, global.scaleFill);\n")
            continue
        if stripped.startswith("window_set_size(384 * _trueScale, 216 * _trueScale);"):
            new_lines.append(f"{indent}window_set_size(global.SCREEN_WIDTH, global.SCREEN_HEIGHT);\n")
            continue

        # Change var _okay to _okay
        if stripped == "var _okay = scrGetOkay(\"menu_misc_defaults_restored\");":
            new_lines.append(f"{indent}_okay = scrGetOkay(\"menu_misc_defaults_restored\");\n")
            continue

        new_lines.append(line)

    with open(file_path, "w") as f:
        f.writelines(new_lines)
    print(f"Modified {filename} with preserved indentation.")


def modify_scrSaveConfig(gml_dir):
    """Modify gml_GlobalScript_scrSaveConfig.gml to insert new config writes with preserved indentation."""
    filename = "gml_GlobalScript_scrSaveConfig.gml"
    file_path = os.path.join(gml_dir, filename)

    if not os.path.isfile(file_path):
        print(f"Warning: {filename} not found, skipping.")
        return

    with open(file_path, "r") as f:
        lines = f.readlines()

    new_lines = []

    for line in lines:
        stripped = line.strip()
        indent = line[:len(line) - len(line.lstrip())]

        # Insert new config writes after scanlines
        if stripped == "scrWriteConfig(\"scanlines\", global.scanlines);":
            new_lines.append(line)
            new_lines.append(f"{indent}scrWriteConfig(\"integerScale\", global.integerScale);\n")
            new_lines.append(f"{indent}scrWriteConfig(\"filter\", global.dispFilter);\n")
            continue

        new_lines.append(line)

    with open(file_path, "w") as f:
        f.writelines(new_lines)
    print(f"Modified {filename} with preserved indentation.")

def main(gml_dir):
    """Modify all specified GML scripts for UFO 50."""
    modify_scrInitDisplay(gml_dir)
    modify_scrScaleDisplay(gml_dir)
    modify_scrSetDisplayDefaults(gml_dir)
    modify_oScreenHandler_Draw_75(gml_dir)
    modify_oPauseMenu_Other_14(gml_dir)
    modify_scrSaveConfig(gml_dir)

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: mod.py <gml_directory>")
        sys.exit(1)
    main(sys.argv[1])