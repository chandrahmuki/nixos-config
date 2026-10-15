# TinyMugg themes

A theme is one JSON file. The built-in ones live here; yours go in
`~/.config/player/themes/` (a file with the same name replaces the built-in one).
`t` / `T` in the player switch themes and re-read the files, so you can edit a theme
and press `t` to see it. `player theme` lists the names, `player theme neon` picks one.

## The quick way: a new look in a minute

```
player theme new mine neon      # creates ~/.config/player/themes/mine.json, starting from neon
```

The file extends `neon` and only holds its colors, so there is nothing to count:

```json
{ "extends": "neon", "label": "mine", "colors": { "frame": "#ff87d7", "accent": "#ffaf5f", ... } }
```

Change a hex value, press `t` in the player until you land on `mine`, repeat. A theme that
`extends` another one takes everything from it and replaces only what it defines: `colors`
and `frame` are merged key by key, `rows` replaces the layout whole. So you can also keep the
colors and write only your own `rows`.

## The format

The box is 48 columns wide and the Super+M scratchpad is sized for **17 rows**.

```json
{
  "label": "Pastel",
  "order": 1,
  "colors": { "frame": "#d7afff", "accent": "#ffafd7", "alt": "#afffd7", "dim": "#8c9694" },
  "frame":  { "v": "│", "color": "frame", "pad": 1 },
  "rows": [ ... ]
}
```

- `colors`: names → `#rrggbb`. The names `frame`, `accent`, `alt` and `dim` are used by the
  search prompt, the messages and the list; define them. Anywhere a color is expected a
  literal `#rrggbb` also works.
- `frame`: the vertical border of every row (`v`), its color and the space around the content.
- `rows`: top to bottom, one entry per terminal row (a few kinds expand to several).

## Row kinds

| row | what it draws |
| --- | --- |
| `{}` | an empty row |
| `{ "segs": [ seg, ... ] }` | a row of colored segments |
| `{ "edge": ["╭","─","╮"], "text": [seg], "align": "left\|center\|right" }` | a horizontal edge, with an optional text inset in it |
| `{ "edge": [...], "status": true }` | the bottom edge: the search prompt, the last message or the hint |
| `{ "list": { "rows": 6 } }` | the playlist (the search results while searching) |
| `{ "viz": { "rows": 2, "bars": 22 } }` | the CAVA spectrum, `rows` rows tall |

`list` options: `fmt` (default `{cursor}{play} {num} {name:34}`), `cursor`, `note`, and the colors
`sel` (the cursor row), `playing`, `dim`. `fmt` knows `{cursor} {play} {n} {num} {name}` (`{num}` is the track number padded to the width of the list size, so the names line up).

`viz` options: `colors` (a gradient from left to right) or `rowcolors` (one color per row,
top first), `glyphs` (8 characters, default `▁▂▃▄▅▆▇█`), `gap`, `baseline` (drawn where a
bar is empty), `basecolor`, `bg`.

## Segments

`[color, text]` or `[color, text, background]`.

- `color` is a name or `#rrggbb`. `"accent|dim@shuf"` is `accent` while the flag is on and
  `dim` otherwise (flags: `shuf`, `loop`, `paused`, `playing`).
- `text` may contain `{title} {artist} {time} {duration} {pos} {count} {vol} {face} {note}
  {reel} {spin} {title_spaced}`. `{title:20}` cuts or pads to exactly 20 columns.
- Special segments: `["@bar", { "w": 22, "on": "accent", "off": "dim" }]` is the progress bar
  (`"of": "volume"` for the volume, `fill`, `rest`, `head`, `bg` to restyle it);
  `["@clock", { "row": 0, "color": "accent" }]` is row 0 to 2 of the big clock;
  `["@viz", { "bars": 9, "rows": 3, "row": 0 }]` is one row of a spectrum inside a row.

A row never grows past the box: text beyond the width is cut.
