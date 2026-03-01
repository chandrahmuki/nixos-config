# Yazi M3U Playback Specification

## Problem
Yazi often detects `.m3u` playlist files as `text/plain` or `application/octet-stream` rather than strictly by extension. This causes it to fallback to the default text editor ($EDITOR/Neovim) instead of the configured media player (mpv).

## Solution
To guarantee `.m3u` files open with `mpv`, use a **prepend_rule** with specific `mime` matching for `text/*` combined with the `name` glob.

### Configuration (`modules/yazi.nix`)

```nix
programs.yazi.settings.open.prepend_rules = [
  {
    # Catch m3u specifically by extension, even if mime is text
    name = "*.m3u"; 
    mime = "text/*";
    use = "listen";
  }
  {
    # Catch m3u by extension generally
    name = "*.m3u";
    use = "listen";
  }
];

# Opener definition
programs.yazi.settings.opener.listen = [
  {
    run = "\${pkgs.mpv}/bin/mpv --audio-display=no --no-video \"$@\"";
    block = true;
    desc = "Listen";
  }
];
```

## Playlist Generation
To generate robust playlists in shells (Fish/Bash) without quoting issues:

```bash
# Safe generation (handles spaces, avoids escaping hell)
printf "%s\n" *.m4a > playlist.m3u
```
**Avoid** `ls *.m4a > playlist.m3u` as modern `ls` (or `eza`) often adds quotes around filenames with spaces, which breaks `mpv`.
