# TinyMugg radios

In the player, `R` swaps your music for the radio stations; `R` again brings the music
back, on the same track at the same second. `/` searches the station names **and** their
tags (`/lofi`, `/ambient drone`).

The built-in stations are in `radios.json` next to this file. Yours go in
`~/.config/player/radios.json`: same format, a JSON list. Your stations come first (the
order of the file is the priority) and replace a built-in one with the same url.

```json
[
  { "name": "SomaFM Drone Zone", "url": "https://ice2.somafm.com/dronezone-128-mp3", "tags": ["ambient", "drone"] }
]
```

A song title shows when the stream sends one (ICY metadata). A station that is down
just does not play: press `n` for the next one.

## YouTube

Any YouTube link works as a station (mpv plays it through `yt-dlp`), a long ambient video
or a live stream alike. It takes a few seconds to start, and a video has a length and can
be sought, unlike a radio. The built-in list has a few Alienworlds and long sci-fi ambient
videos, tagged `youtube`: `/youtube` or `/alienworlds` finds them. A link that stops
working (video removed) is skipped like a dead station.

A channel or a playlist link works too: when you play it, it unfolds into its videos in the
list (the built-in "Alienworlds · toute la chaîne" gives about 1400), and `/` searches their
titles (`/alien`, `/horror`). Playing it replaces that one row by the videos.
