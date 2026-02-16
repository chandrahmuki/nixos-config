#!/usr/bin/env python3
import json
import os
import sys

# Chemins
COLOR_FILE = os.path.expanduser("~/.config/noctalia/colors.json")
MAKO_CONFIG = os.path.expanduser("~/.config/mako/config")
FUZZEL_CONFIG = os.path.expanduser("~/.config/fuzzel/fuzzel.ini")
YAZI_CONFIG = os.path.expanduser("~/.config/yazi/theme.toml")

def load_colors():
    if not os.path.exists(COLOR_FILE):
        print(f"Error: {COLOR_FILE} not found")
        sys.exit(1)
    with open(COLOR_FILE, 'r') as f:
        return json.load(f)

def update_mako(colors):
    background = colors.get("mSurface", "#1e1e2e") + "ee"
    text = colors.get("mOnSurface", "#cdd6f4")
    border = colors.get("mPrimary", "#89b4fa")
    
    # On garde la structure mais on injecte les couleurs
    config = f"""[main]
anchor=top-right
layer=top
width=400
height=200
margin=10
padding=12
border-size=2
border-radius=8
background-color={background}
text-color={text}
border-color={border}
progress-color={colors.get("mSecondary", "#313244")}
default-timeout=5000

[urgency=critical]
default-timeout=0
border-color={colors.get("mError", "#f38ba8")}
"""
    os.makedirs(os.path.dirname(MAKO_CONFIG), exist_ok=True)
    with open(MAKO_CONFIG, 'w') as f:
        f.write(config)
    os.system("makoctl reload")

def update_fuzzel(colors):
    # Fuzzel attend RRGGBBAA
    bg = colors.get("mSurface", "#111415").replace("#", "") + "ff"
    fg = colors.get("mOnSurface", "#e1e3e4").replace("#", "") + "ff"
    primary = colors.get("mPrimary", "#53d7f1").replace("#", "") + "ff"
    
    config = f"""[main]
font=Hack Nerd Font:size=18
terminal=ghostty
prompt='❯ '
layer=overlay
icons-enabled=yes
icon-theme=Papirus-Dark
width=40
lines=15

[colors]
background={bg}
text={fg}
match={primary}
selection={colors.get("mSurfaceVariant", "#1d2021").replace("#", "")}ff
selection-text={fg}
border={primary}

[border]
width=2
radius=10
"""
    os.makedirs(os.path.dirname(FUZZEL_CONFIG), exist_ok=True)
    with open(FUZZEL_CONFIG, 'w') as f:
        f.write(config)

def update_yazi(colors):
    # Yazi theme.toml (simplifié)
    primary = colors.get("mPrimary", "#53d7f1")
    surface = colors.get("mSurface", "#111415")
    on_surface = colors.get("mOnSurface", "#e1e3e4")
    
    config = f"""[manager]
cwd = {{ fg = "{primary}" }}
hovered = {{ fg = "{surface}", bg = "{primary}", bold = true }}
preview_hovered = {{ underline = true }}

[status]
separator_open  = ""
separator_close = ""
separator_style = {{ fg = "{surface}", bg = "{surface}" }}
"""
    os.makedirs(os.path.dirname(YAZI_CONFIG), exist_ok=True)
    with open(YAZI_CONFIG, 'w') as f:
        f.write(config)

if __name__ == "__main__":
    colors = load_colors()
    update_mako(colors)
    update_fuzzel(colors)
    update_yazi(colors)
    print("Mako, Fuzzel and Yazi colors updated!")
