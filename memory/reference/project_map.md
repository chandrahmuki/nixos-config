---
name: NixOS Config Project Map
description: Compact index — modules, entry points, flake inputs, host info
type: reference
---
host=muggy-nixos  user=david  arch=x86_64-linux

## Entry Points
```
flake.nix                     # Root + inputs
home.nix                      # HM entry → modules/default.nix
hosts/system/default.nix      # Boot, AMD GPU, greetd+niri
hosts/system/hardware-configuration.nix  # AUTO-GEN, never edit
overlays.nix                  # niri, opencode, deno, openldap
modules/default.nix           # Auto-imports all modules/*.nix
lib/colors.nix                # Tokyonight palette
```

## Inputs
```
nixpkgs(unstable) nixpkgs-master home-manager niri noctalia
nix-cachyos walker elephant sops-nix opencode zen-browser
```

## Modules [tag]
```
ai[hm] backup[nixos] bluetooth[nixos] btop[hm] direnv[hm]
discord[hm] font[nixos] gaming[nixos] git[hm] media[hm]
microfetch[hm] nautilus[hm] neovim[hm] nh[both] niri[both]
noctalia[hm] notifications[hm] obsidian[hm] parsec[hm] pdf[hm]
performance-tuning[nixos] secrets[nixos] tealdeer[hm] terminal[hm]
theme[hm] utils[hm] vscode[hm] walker[hm] xdg[hm] yazi[hm]
zellij[hm] zen-browser[both]
```

## Design
- HM wired as NixOS module | specialArgs: `{inputs,username,hostname}`
- Colors centralized `lib/colors.nix`
- Build:`nos` | Rollback:`nos --rollback`