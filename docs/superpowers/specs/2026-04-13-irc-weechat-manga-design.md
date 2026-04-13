# IRC Weechat Manga Download Module — Design Spec

## Summary

Add a NixOS module (`modules/irc.nix`) that installs and configures Weechat as a CLI IRC client, pre-configured to connect to Rizon and join `#kanadi` for manga downloads via XDCC.

## Approach

**Approche A — Module NixOS pur**: Single declarative HM module using `programs.weechat` and `home.file` for full configuration. No scripts, no services — everything is declarative and reproducible.

## Module Architecture

**File**: `modules/irc.nix`

**NixOS-level**: None (no system services needed)

**Home Manager-level**: All Weechat configuration
- `programs.weechat` for declarative Weechat config
- `home.packages` for Weechat (with python3 + perl extras) and dependencies
- `home.file` for installing Weechat scripts into `~/.local/share/weechat/python/` and `~/.local/share/weechat/perl/`
- `home.file."Downloads/manga/.keep"` to ensure download directory exists

**Auto-import**: Automatically picked up by `modules/default.nix` scanModules — no manual registration needed.

## IRC Network Configuration

- **Server**: `irc.rizon.net`, port 6697, TLS enabled
- **Auto-connect** on Weechat startup
- **Auto-join**: `#kanadi`

## Weechat Scripts

Installed via `pkgs.fetchurl` from `weechat.org/scripts/` and placed via `home.file`:

| Script | Language | Purpose |
|--------|----------|---------|
| `xdcc` | Python | List and download XDCC packs from bots |
| `autojoin.py` | Python | Save and restore joined channels |
| `buffer.pl` | Perl | Advanced buffer management |
| `highmon.pl` | Perl | Highlight monitor for notifications |
| trigger scripts | Built-in | Notify on new packs via libnotify |

## Key Configuration

- **Download directory**: `~/Downloads/manga/`
- **Notifications**: via `libnotify` (already configured in `notifications.nix`)
- **Unlimited history** on XDCC buffers
- **Auto-resize nicklist**

## Module Parameters

```nix
{ config, lib, pkgs, username, inputs, ... }:
```

No hardcoded `david` or `muggy-nixos` — uses `username` param per AGENTS.md rules.

## Packages

- `weechat` (with `python3` and `perl` script extras)
- Python dependencies for XDCC script

## Validation

- `nix eval` after any change to catch syntax errors
- Manual test: launch `weechat`, verify auto-connect to Rizon + auto-join `#kanadi`
- Run `alejandra --check .`, `deadnix --check .`, `statix check .` before committing

## Future Considerations

- Can evolve to Approach C (systemd detached Weechat) if always-on downloads are desired
- Can add more channels/servers via the same `programs.weechat` settings