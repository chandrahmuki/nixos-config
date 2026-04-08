---
name: NixOS Config Project Map
description: Compact index of the nixos-config repo — modules, entry points, flake inputs, host info. Read this instead of scanning the codebase.
type: reference
---

# NixOS Config Map
host=muggy-nixos  user=david  arch=x86_64-linux
channels: nixpkgs-unstable + nixpkgs-master

## Entry Points
```
flake.nix                          # Root — inputs, nixosSystem wiring
home.nix                           # HM entry point (imports modules/default.nix)
hosts/system/default.nix           # Bootloader, AMD GPU, networking, greetd+niri login
hosts/system/hardware-configuration.nix  # AUTO-GENERATED — never edit
overlays.nix                       # Package overrides (niri, opencode, deno fix)
modules/default.nix                # Auto-imports all *.nix in modules/ recursively
lib/colors.nix                     # Shared Tokyonight color definitions
```

## Flake Inputs
```
nixpkgs              github:nixos/nixpkgs/nixos-unstable
nixpkgs-master       github:nixos/nixpkgs/master
home-manager         follows nixpkgs
niri                 github:sodiboo/niri-flake
noctalia             github:noctalia-dev/noctalia-shell
nix-cachyos          github:xddxdd/nix-cachyos-kernel/release
walker               github:abenz1267/walker
elephant             github:abenz1267/elephant  (dep of walker)
sops-nix             github:Mic92/sops-nix
opencode             github:anomalyco/opencode  (overlay in overlays.nix)
```

## Modules
Tags: [nixos]=system-level  [hm]=Home Manager  [both]=both  [secrets]=SOPS

```
ai.nix                AI tools (claude-code, opencode, gemini)      [hm]
backup.nix            btrbk Btrfs snapshots service                  [nixos]
bluetooth.nix         Bluetooth stack                               [nixos]
brave.nix             Brave browser config + extensions              [both]
btop.nix              btop system monitor                           [hm]
direnv.nix            direnv + nix-direnv                           [hm]
discord.nix           Discord                                       [hm]
font.nix              Nerd fonts, Noto, emoji fonts                 [nixos]
gaming.nix            Steam, GameMode, LACT, GPU screen recorder    [nixos]
git.nix               Git config                                    [hm]
media.nix             mpv, yt-dlp, music-menu, yt-search            [hm]
microfetch.nix        Microfetch system info display                [hm]
nautilus.nix          Nautilus file manager                          [hm]
neovim.nix            Neovim + LSP config                          [hm]
nh.nix                nh nix helper + fish aliases                  [both]
niri.nix              Niri Wayland compositor config                [both]
noctalia.nix          Noctalia shell theme                          [hm]
notifications.nix     libnotify (noctalia handles daemon)           [hm]
obsidian.nix          Obsidian notes                                [hm]
parsec.nix            Parsec remote gaming                          [hm]
pdf.nix               Zathura PDF viewer                            [hm]
performance-tuning.nix  CPU/kernel performance settings             [nixos]
secrets.nix           SOPS-Nix encrypted secrets                    [nixos,secrets]
tealdeer.nix          tldr pages (tealdeer)                         [hm]
terminal.nix          Foot terminal + Fish shell + Starship         [hm]
theme.nix             GTK theme (Tokyonight)                         [hm]
utils.nix             CLI utils: fd, dust, gdu, jq, etc.            [hm]
vscode.nix            VS Code                                       [hm]
walker.nix            Walker app launcher                           [hm]
xdg.nix               XDG user dirs                                 [hm]
yazi.nix              Yazi TUI file manager                         [hm]
zellij.nix            Zellij terminal workspace + dev layout        [hm]
```

## Key Design Notes
- All modules auto-imported via `modules/default.nix` (recursive scan)
- HM wired as NixOS module (not standalone) — `home-manager.users.david`
- `specialArgs`/`extraSpecialArgs`: `{inputs, username, hostname}`
- Theme colors centralized in `lib/colors.nix` (Tokyonight palette)
- No antigravity, tmux, mako, or fuzzel — removed during rearchitecture
- Build: `nos` (nh os switch) | rollback: `nos --rollback`