---
name: NixOS Config Project Map
description: Compact index — modules, entry points, flake inputs, host info
type: reference
---
host=muggy-nixos  user=david  arch=x86_64-linux

## Entry Points
```
flake.nix                     # Root + inputs
home.nix                      # HM user entry
aspects/den.nix               # Den schema, host, user
aspects/compatibility.nix     # Remaining legacy modules routed through Den
hosts/system/default.nix      # Boot, AMD GPU, base system
hosts/system/hardware-configuration.nix  # AUTO-GEN, never edit
overlays.nix                  # niri, opencode, deno, openldap
lib/colors.nix                # Tokyonight palette
```

## Inputs
```
nixpkgs(unstable) nixpkgs-master home-manager niri noctalia
nix-cachyos sops-nix opencode zen-browser den import-tree
```

## Native Den Aspects [tag]
```
bluetooth[nixos] btop[hm] direnv[hm] discord[hm] font[nixos]
gaming[nixos] git[hm] greetd[nixos] helium[hm] herdr[hm]
microfetch[hm] nautilus[nixos] nh[both] noctalia[hm]
notifications[hm] obsidian[hm] oculante[hm] openvpn[nixos]
parsec[hm] pdf[hm] tealdeer[hm] xdg[hm] yazi[hm]
zen-browser[hm]
```

## Compatibility Modules via Den
```
ai backup cliamp fuzzel gnome helix irc media neovim niri
performance-tuning secrets stylix terminal theme utils vscode
walker zellij
```

## Design
- Den host/user aspects with incremental compatibility imports
- Legacy modules retain `{inputs,username,hostname}` specialArgs
- Colors centralized `lib/colors.nix`
- Build:`nos` | Rollback:`nos --rollback`
