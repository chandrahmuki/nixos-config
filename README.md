# NixOS Configuration

NixOS flake for a single x86_64 GNOME desktop, built with Home Manager, Den aspects and optional SOPS-Nix secrets.

![GNOME desktop](assets/gnome-desktop.png)

It is a reusable personal configuration, not a hardware image: adapt `settings.nix` and generate a hardware module before building.

## Install

```sh
git clone https://github.com/chandrahmuki/nixos-config.git
cd nixos-config
sudo nixos-generate-config --show-hardware-config > hosts/system/hardware-configuration.nix
git update-index --skip-worktree hosts/system/hardware-configuration.nix
nix flake check --no-build
sudo nixos-rebuild build --flake .#<hostname>
```

Replace `<hostname>` with the `hostname` set in `settings.nix`. Review the build, then activate it with your normal NixOS deployment command.

## Customize `settings.nix`

All identity and locale values live in one place:

- `username`, `hostname` and `system`
- `configDirectory`, used by Helix and Neovim's Nix language server
- `timeZone` and `locale`
- profile aspect lists

The `desktop` and `user` lists are the GNOME base. `personalDesktop` and `personalUser` are empty by default; add aspect names for optional applications such as AI tools, browsers, gaming, media, Teams or VPN support.

`machineDesktop` is empty by default. Add `machine-storage` to create matching XDG links and schedule Btrfs scrubbing for configured Btrfs filesystems. Add `backup` only for this repository's `/mnt/btrfs-system` to `/mnt/backup` btrbk layout.

## Secrets and hardware

Keep SOPS material outside the repository, in `~/.config/nixos-secrets/`, if you use it. The committed hardware module is only a generic template; replace it with the output from `nixos-generate-config` and keep it marked `skip-worktree` so real disk identifiers cannot be committed accidentally.

## Layout

```text
settings.nix              Identity, locale and selected profiles
flake.nix                 Flake inputs and host definition
hosts/system/             Generic hardware template; replace before building
aspects/                  NixOS and Home Manager aspects
overlays.nix              Package overlays
wallpapers/               Local visual assets
```

Mesa is pinned in `flake.nix` for a known multi-monitor Parsec/XWayland issue. Review this pin before changing graphics packages.

## License

[MIT License](LICENSE)
