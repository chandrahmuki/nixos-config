# NixOS Configuration

![NixOS](https://img.shields.io/badge/NixOS-Unstable-blue?style=for-the-badge&logo=nixos&logoColor=white)

Single-host NixOS flake with Home Manager, Niri (Wayland), and gaming/productivity optimizations.

## Architecture

```
flake.nix              # Entry point
home.nix               # HM entry (auto-imports modules/)
hosts/system/          # Bootloader, AMD GPU, greetd+niri
modules/               # Auto-discovered modules (32 files)
lib/colors.nix         # Shared Tokyonight color palette
```

Modules are auto-imported via `modules/default.nix` — just drop a `.nix` file in and it's loaded.

## Build & Deploy

```bash
nos                    # Apply configuration (nh os switch)
nos --rollback         # Revert to previous generation
nix flake check        # Validate flake
nix flake update       # Update all inputs
nh clean all           # Remove old generations
```

## Key Modules

| Module | Description |
|--------|-------------|
| ai.nix | Claude Code, OpenCode, Gemini CLI |
| gaming.nix | Steam, GameMode, LACT, GPU screen recorder |
| media.nix | mpv, yt-dlp, music-menu, yt-search |
| niri.nix | Niri compositor config + keybinds |
| terminal.nix | Foot terminal + Fish + Starship |
| theme.nix | Tokyonight GTK theme |

## Credits

- [Niri](https://github.com/YaLTeR/niri) — Wayland compositor
- [Noctalia](https://github.com/noctalia-dev/noctalia-shell) — Shell customization
- [Home Manager](https://github.com/nix-community/home-manager) — User config
- [CachyOS Kernel](https://github.com/CachyOS/kernel-patches) — Optimized kernel

## License

[MIT License](LICENSE)