---
Generated: 2026-04-03 UTC
---

# Session Summary — Flake Update + Deno Build Fix

## Contexte
Session de debugging suite à un `nix flake update` qui a cassé le build avec deux erreurs en cascade : claude-code 2.1.88 (404 npm) et deno 2.7.9 (tests cassés).

## Ce qui a été fait

### 1. Fix claude-code 2.1.88 → pkgs-master
- Version 2.1.88 dépubliée sur npm → 404 à la compilation
- Fix : prise de `claude-code` depuis `nixpkgs-master` (2.1.90) dans `modules/claude.nix`
- Pattern : `pkgs-master = import inputs.nixpkgs-master { ... }` puis `pkgs-master.claude-code`

### 2. Découverte : deno 2.7.9 cassé dans nixpkgs
- yt-dlp (depuis master) dépend de deno
- deno 2.7.9 mergé dans nixpkgs master le 3 avril 2026 (même jour) — tests TTY cassés + SIGSEGV
- Pas de binaire dans cache.nixos.org → compile locale obligatoire (~45 min)
- Issue nixpkgs : #417331 (build failure deno)

### 3. Fix deno : overlay doCheck = false
- Tentative 1 : overlay `deno = prev.deno.overrideAttrs (_: { doCheck = false; })` dans overlays.nix
- Échec : yt-dlp venait de `nixpkgs-master.legacyPackages` → deno de master sans overlay
- Tentative 2 : suppression de l'override `yt-dlp → master` (même version 2026.03.17 de toute façon)
- Résultat : deno d'unstable utilisé avec overlay `doCheck = false` → build réussi

### 4. Commit
`4a5b4fc` — fix: flake update — claude-code 404 npm + deno 2.7.9 tests cassés
- claude.nix, overlays.nix, flake.lock, CLAUDE.md

### 5. Informations annexes
- `programs.nh.clean` = GC automatique configuré (--keep-since 7d --keep 5)
- Warning `'system' has been renamed to stdenv.hostPlatform.system` = vient des inputs (niri, etc.), pas de la config
- Claude Pro vs API : indépendants, CLI utilise l'API séparément
