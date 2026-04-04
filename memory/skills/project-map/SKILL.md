---
name: project-map
description: Regenerate the compact NixOS config project map and save it to memory. Use this when the user asks to "map the project", "update the project map", "/project-map", or when new modules have been added and the map needs refreshing.
---

# Project Map — NixOS Config

Scan the NixOS config repo at `/home/david/nixos-config` and regenerate the compact project index at `/home/david/.claude/projects/-home-david-nixos-config/memory/reference/project_map.md`.

## Process

1. Run `find /home/david/nixos-config/modules -name "*.nix" ! -name "default.nix" | sort` to get current module list (exclude `.worktrees/`)
2. For modules whose purpose isn't obvious from the filename, read the first 5–8 lines only
3. Infer tags:
   - `[nixos]` — top-level NixOS options (`services.*`, `environment.*`, `boot.*`, `fonts.*`, etc.)
   - `[hm]` — wrapped in `home-manager.users.*`
   - `[both]` — contributes to both
   - `[secrets]` — uses SOPS/age
   - `[pkg]` — custom/overlay package
4. Rewrite the map file with the format below — keep it compact, no prose

## Output Format

```
# NixOS Config Map
host=...  user=...  arch=...
channels: ...

## Entry Points
(key files with one-line role)

## Flake Inputs
(name  source  [follows])

## Modules
Tags: ...
(filename  description  [tags])

## Key Design Notes
(3–5 bullet facts that aren't obvious from filenames)
```

## Save

Overwrite `/home/david/.claude/projects/-home-david-nixos-config/memory/reference/project_map.md` with the new map (keep the frontmatter).

Confirm to the user: "Map updated — N modules indexed."
