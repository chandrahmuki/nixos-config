#!/usr/bin/env python3
"""Flag a Matugen result whose generated colour drifted onto a different hue
than the theme it's supposed to represent.

Matugen picks its palette from the wallpaper image, not from the curated
swatches in shell.qml — so a wallpaper chosen for looks (not colour
extraction) can silently hand a "Tokyo Night" theme a pink/salmon accent
instead of blue. That exact bug shipped once already; this catches it
before a human has to eyeball eight theme switches to notice.

Usage: theme-color-check.py <theme_id> <matugen_json_file_or_->
Exit 0 and prints "OK <hue_diff>deg" if within HUE_THRESHOLD of the
curated shell.qml accent for that theme; exit 1 and prints why otherwise.
"""
import colorsys
import json
import re
import sys
from pathlib import Path

HUE_THRESHOLD = 60  # degrees; generous — this flags drift, not nuance

REPO_ROOT = Path(__file__).resolve().parent.parent
SHELL_QML = REPO_ROOT / "quickshell" / "shell.qml"


def hex_to_hue(hex_color: str) -> float:
    hex_color = hex_color.lstrip("#")
    r, g, b = (int(hex_color[i : i + 2], 16) / 255 for i in (0, 2, 4))
    h, _l, s = colorsys.rgb_to_hls(r, g, b)
    return h * 360, s


def hue_distance(a: float, b: float) -> float:
    d = abs(a - b) % 360
    return min(d, 360 - d)


def reference_accent(theme_id: str) -> str:
    text = SHELL_QML.read_text()
    # Each theme is one line: { id: "nord", ..., accent: "#81a1c1", ... }
    for line in text.splitlines():
        if f'id: "{theme_id}"' not in line:
            continue
        m = re.search(r'accent:\s*"(#[0-9a-fA-F]{6})"', line)
        if m:
            return m.group(1)
    raise ValueError(f"no accent found for theme id '{theme_id}' in {SHELL_QML}")


def main() -> int:
    if len(sys.argv) != 3:
        print("usage: theme-color-check.py <theme_id> <matugen_json_file_or_->", file=sys.stderr)
        return 2
    theme_id, json_arg = sys.argv[1], sys.argv[2]

    raw = sys.stdin.read() if json_arg == "-" else Path(json_arg).read_text()
    try:
        data = json.loads(raw)
        generated_hex = data["colors"]["primary"]["dark"]["color"]
    except (json.JSONDecodeError, KeyError) as e:
        print(f"FAIL {theme_id}: could not read colors.primary.dark.color from Matugen output ({e})")
        return 1

    try:
        expected_hex = reference_accent(theme_id)
    except ValueError as e:
        print(f"FAIL {theme_id}: {e}")
        return 1

    gen_hue, gen_sat = hex_to_hue(generated_hex)
    ref_hue, ref_sat = hex_to_hue(expected_hex)

    # A near-grey generated colour has no reliable hue at all (low
    # saturation) — comparing hues there is noise, not signal. Likewise if
    # the *reference* itself is close to neutral, skip the hue check.
    if gen_sat < 0.12 or ref_sat < 0.12:
        print(f"SKIP {theme_id}: colour too desaturated to judge hue reliably "
              f"(generated {generated_hex} sat={gen_sat:.2f}, reference {expected_hex} sat={ref_sat:.2f})")
        return 0

    diff = hue_distance(gen_hue, ref_hue)
    if diff > HUE_THRESHOLD:
        print(f"FAIL {theme_id}: generated primary {generated_hex} (hue {gen_hue:.0f}°) is "
              f"{diff:.0f}° away from the curated accent {expected_hex} (hue {ref_hue:.0f}°) — "
              f"likely wrong wallpaper crop or a bad --prefer choice for this theme")
        return 1

    print(f"OK {theme_id}: generated primary {generated_hex} is {diff:.0f}° from curated accent {expected_hex}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
