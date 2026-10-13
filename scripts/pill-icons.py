#!/usr/bin/env python3
"""Draws the 16x16 pixel-art icons of the Quickshell pill into quickshell/assets/icons/.

Edit the art below, run this script, commit the SVGs. The icons are white: the
PixelIcon component tints them with the theme colour. Use a multiple of 16 px
for their size so that the pixels stay crisp.
"""
import os

OUT = os.path.join(os.path.dirname(__file__), "..", "quickshell", "assets", "icons")
SIZE = 16


def grid(rows, top=0):
    g = [[False] * SIZE for _ in range(SIZE)]
    for dy, row in enumerate(rows):
        assert len(row) <= SIZE, row
        for x, ch in enumerate(row):
            if ch == "X":
                g[top + dy][x] = True
    return g


def merge(*layers):
    g = [[False] * SIZE for _ in range(SIZE)]
    for layer in layers:
        for y in range(SIZE):
            for x in range(SIZE):
                g[y][x] = g[y][x] or layer[y][x]
    return g


def shift(g, dx, dy):
    out = [[False] * SIZE for _ in range(SIZE)]
    for y in range(SIZE):
        for x in range(SIZE):
            if g[y][x] and 0 <= x + dx < SIZE and 0 <= y + dy < SIZE:
                out[y + dy][x + dx] = True
    return out


def halo(g):
    """The icon grown by one pixel, to clear what lies behind it."""
    out = [[False] * SIZE for _ in range(SIZE)]
    for y in range(SIZE):
        for x in range(SIZE):
            if g[y][x]:
                for ay in (-1, 0, 1):
                    for ax in (-1, 0, 1):
                        if 0 <= x + ax < SIZE and 0 <= y + ay < SIZE:
                            out[y + ay][x + ax] = True
    return out


def behind(front, back):
    clear = halo(front)
    return merge(front, [[back[y][x] and not clear[y][x] for x in range(SIZE)] for y in range(SIZE)])


SUN = grid([
    "", ".......XX.......", ".......XX.......", "...X...XX...X...", "....X......X....", ".....XXXXXX.....",
    "....XXXXXXXX....", "XX..XXXXXXXX..XX", "XX..XXXXXXXX..XX", "....XXXXXXXX....", ".....XXXXXX.....",
    "....X......X....", "...X...XX...X...", ".......XX.......", ".......XX.......",
])
SMALL_SUN = grid(["...X...", ".X...X.", "..XXX..", "X.XXX.X", "..XXX..", ".X...X.", "...X..."])
CLOUD = grid([
    "", "", ".......XXXX.....", ".....XXXXXXXX...", "....XXXXXXXXXX..", "...XXXXXXXXXXXX.", "..XXXXXXXXXXXXX.",
    ".XXXXXXXXXXXXXX.", ".XXXXXXXXXXXXXX.", ".XXXXXXXXXXXXXX.", "..XXXXXXXXXXXX..",
])

ICONS = {
    "ethernet": grid([
        "", "", "..XXXXXXXXXXXX..", "..X..........X..", "..X.X.X.X.X..X..", "..X.X.X.X.X..X..",
        "..X..........X..", "..XXXX....XXXX..", ".....X....X.....", ".....XXXXXX.....",
    ]),
    "wifi": grid([
        "", "....XXXXXXXX....", "..XXX......XXX..", ".XX..........XX.", "XX............XX", "",
        ".....XXXXXX.....", "...XXX....XXX...", "..XX........XX..", "", "......XXXX......", ".....XX..XX.....", "",
        ".......XX.......", ".......XX.......",
    ]),
    "volume": grid([
        "", "......X.........", ".....XX....X....", "....XXX.....X...", "XXXXXXX..X..X...", "XXXXXXX..X...X..",
        "XXXXXXX..X...X..", "XXXXXXX..X..X...", "....XXX.....X...", ".....XX....X....", "......X.........",
    ]),
    "volume-low": grid([
        "", "......X.........", ".....XX.........", "....XXX....X....", "XXXXXXX.....X...", "XXXXXXX..X..X...",
        "XXXXXXX..X..X...", "XXXXXXX.....X...", "....XXX....X....", ".....XX.........", "......X.........",
    ]),
    "volume-muted": grid([
        "", "......X.........", ".....XX.........", "....XXX..X...X..", "XXXXXXX...X.X...", "XXXXXXX....X....",
        "XXXXXXX...X.X...", "XXXXXXX..X...X..", "....XXX.........", ".....XX.........", "......X.........",
    ]),
    "sun": SUN,
    "cloud": CLOUD,
    "partly-cloudy": behind(shift(CLOUD, 1, 4), SMALL_SUN),
    "rain": grid([
        "", ".....XXXX.......", "...XXXXXXXX.....", "..XXXXXXXXXX....", ".XXXXXXXXXXXX...", ".XXXXXXXXXXXX...",
        "..XXXXXXXXXX....", "", "...X...X...X....", "...X...X...X....", "..X...X...X.....", "..X...X...X.....",
    ]),
    "fog": merge(shift(CLOUD, 0, -1), grid(["", "", "", "", "", "", "", "", "", "", "..XXXXXXXXXXXX..", "", "....XXXXXXXXXX..", "", "..XXXXXXXXXXXX.."])),
    "thunder": merge(shift(CLOUD, 0, -2), grid([
        "", "", "", "", "", "", "", "", "", "........XX......", ".......XX.......", "......XXXX......",
        "........XX......", ".......XX.......", "......X.........",
    ])),
    "snow": merge(shift(CLOUD, 0, -1), grid([
        "", "", "", "", "", "", "", "", "", "", "...X...X...X....", "..XXX.XXX.XXX...", "...X...X...X....", "",
        "......X...X.....",
    ])),
    "headset": grid([
        "", "....XXXXXXXX....", "...XX......XX...", "..XX........XX..", "..X..........X..", "..X..........X..",
        ".XXX........XXX.", ".XXX........XXX.", ".XXX........XXX.", ".XXX........XXX.", ".XXX........XXX.", "..XX........XX..",
        "",
    ]),
}
# a slash over the wifi icon when there is no connection
slash = [[False] * SIZE for _ in range(SIZE)]
for i in range(2, 14):
    slash[i][i] = True
ICONS["wifi-off"] = merge(ICONS["wifi"], slash)


def svg(g):
    rects = []
    for y in range(SIZE):
        x = 0
        while x < SIZE:
            if g[y][x]:
                e = x
                while e < SIZE and g[y][e]:
                    e += 1
                rects.append(f'<rect x="{x}" y="{y}" width="{e - x}" height="1"/>')
                x = e
            else:
                x += 1
    return ('<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 16 16" '
            'fill="#ffffff" shape-rendering="crispEdges">' + "".join(rects) + "</svg>\n")


if __name__ == "__main__":
    os.makedirs(OUT, exist_ok=True)
    for name, g in ICONS.items():
        with open(os.path.join(OUT, name + ".svg"), "w") as f:
            f.write(svg(g))
    print(f"{len(ICONS)} icons written to {os.path.normpath(OUT)}")
