# Shell & Multimedia Toolchain Specs

## Problem
Filenames containing spaces or quotes often break shell loops and playlist generation. Default `ls` behavior (quoting) and `yt-dlp` output format exacerbate this.

## Solutions

### 1. yt-dlp Configuration (`modules/yt-dlp.nix`)
Force `yt-dlp` to restrict filenames to ASCII characters (removing spaces and quotes automatically).

```nix
programs.yt-dlp.settings = {
  restrict-filenames = true; # Essential
  windows-filenames = true;  # Optional compatibility
};
```

### 2. Rename Files (Remove Quotes)
To safely remove single quotes from filenames in a directory:

**Python (Safest, No Shell Escaping Issues):**
```python
import os
for f in os.listdir("."):
    if "'" in f: os.rename(f, f.replace("'", ""))
```

**Fish (Native):**
```fish
for f in *"'*"; mv -v "$f" (string replace -a "'" "" "$f"); end
```

### 3. Generate File Lists (Playlists)
Avoid `ls` which adds quotes. Use `printf`:

```bash
# Works in Bash & Fish
printf "%s\n" *.m4a > playlist.m3u
```
