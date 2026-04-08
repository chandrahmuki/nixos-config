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
overlays.nix                       # Package overrides
pkgs/google-antigravity/default.nix  # Custom pkg
modules/default.nix                # Auto-imports all *.nix in modules/ recursively
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
Tags: [nixos]=system-level  [hm]=Home Manager  [both]=both  [secrets]=SOPS  [pkg]=custom package

```
antigravity.nix       Google Antigravity browser extension          [hm,pkg]
backup.nix            btrbk Btrfs snapshots service                 [nixos]
bluetooth.nix         Bluetooth stack                               [nixos]
brave.nix             Brave browser config                          [hm]
btop.nix              btop system monitor                           [hm]
claude.nix            Claude Code CLI config                        [hm]
direnv.nix            direnv + nix-direnv                           [hm]
discord.nix           Discord                                       [hm]
font.nix              Nerd fonts, Noto, emoji fonts                 [nixos]
gemini.nix            Gemini AI CLI                                 [hm]
git.nix               Git config                                    [hm]
lact.nix              LACT AMD GPU control tool                     [nixos]
microfetch.nix        Microfetch system info display                [hm]
music-menu.nix        yt-search music player menu (rofi/walker UI)  [hm]
nautilus.nix          Nautilus file manager                         [hm]
neovim.nix            Neovim + LSP config                          [hm]
nh.nix                nh nix helper + fish aliases                  [both]
opencode.nix          OpenCode AI coding agent                      [hm]
niri.nix              Niri Wayland compositor config                [both]
noctalia.nix          Noctalia shell theme                          [hm]
notifications.nix     Mako notification daemon                      [hm]
obsidian.nix          Obsidian notes                                [hm]
parsec.nix            Parsec remote gaming                          [hm]
pdf.nix               Zathura PDF viewer                            [hm]
performance-tuning.nix  CPU/kernel performance settings             [nixos]
secrets.nix           SOPS-Nix encrypted secrets                    [nixos,secrets]
steam.nix             Steam + gaming                                [nixos]
tealdeer.nix          tldr pages (tealdeer)                         [hm]
terminal.nix          Foot terminal + Fish shell + GTK4 css         [hm]
theme.nix             GTK theme (Noctalia)                          [hm]
tmux.nix              Tmux config                                   [hm]
utils.nix             CLI utils: fd, dust, gdu, etc.                [hm]
vscode.nix            VS Code                                       [hm]
walker.nix            Walker app launcher                           [hm]
xdg.nix               XDG user dirs                                 [hm]
yazi.nix              Yazi TUI file manager                         [hm]
yt-dlp.nix            yt-dlp youtube downloader                     [hm]
yt-search.nix         yt-search TUI + mpv music player              [hm]
zellij.nix            Zellij terminal workspace + dev layout        [hm]
```

## Key Design Notes
- All modules auto-imported via `modules/default.nix` (recursive scan)
- HM wired as NixOS module (not standalone) — `home-manager.users.david`
- `specialArgs`/`extraSpecialArgs`: `{inputs, username, hostname}`
- Secrets: SOPS-Nix, encrypted at rest, decrypted at build time
- Build: `nos` (nh os switch) | rollback: `nos --rollback`
