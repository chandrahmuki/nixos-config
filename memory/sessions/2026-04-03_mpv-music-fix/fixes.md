---
Generated: 2026-04-03 14:10 UTC
---

# Bugs Fixed

## yt-search : pkill tuait mpvpaper
**Fichier:** `modules/yt-search.nix`
**Problème:** `pkill mpv` tuait toutes les instances mpv, y compris mpvpaper (fond d'écran animé)
**Fix v1:** `pkill -f "title=yt-player"` + `--title=yt-player` sur le lancement — insuffisant car ne cross-kill pas music-menu
**Fix v2 (final):** titre commun `music-player` pour yt-search ET music-menu → les deux se coupent mutuellement, mpvpaper intact

## Décision de design : titre commun
- `music-menu` : `--title=music-player` (déjà en place)
- `yt-search` : `--title=music-player` (corrigé)
- Les deux font `pkill -f "title=music-player"` avant de lancer
- mpvpaper n'a pas ce titre → jamais tué
