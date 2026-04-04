---
Generated: 2026-04-03 UTC
---

# Bugs Fixed

## 1. claude-code 2.1.88 — 404 npm
**Fichier :** `modules/claude.nix`
**Cause :** Version unpublished sur npm
**Fix :** Prise depuis nixpkgs-master (2.1.90)
```nix
let
  pkgs-master = import inputs.nixpkgs-master { inherit (pkgs) system; config = pkgs.config; };
in
  home.packages = [ pkgs-master.claude-code ];
```

## 2. deno 2.7.9 — tests cassés (TTY + SIGSEGV)
**Fichiers :** `overlays.nix`
**Cause :** deno 2.7.9 mergé dans nixpkgs le 3 avril 2026 avec tests flaky (tty_reset_mode_restores_termios, SIGSEGV dans deno_core)
**Fix :** Overlay `doCheck = false` + suppression override yt-dlp→master
```nix
# overlays.nix — overlay deno sans tests
deno = prev.deno.overrideAttrs (_: { doCheck = false; });
# yt-dlp depuis unstable (pas master) pour que l'overlay s'applique
```
**Piège :** Si yt-dlp vient de `nixpkgs-master.legacyPackages`, son deno échappe à l'overlay unstable
