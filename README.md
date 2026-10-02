# NixOS Configuration

NixOS flake for a modern, high-performance Hyprland desktop with a Quickshell shell, built with Home Manager, [Den](https://github.com/denful/den) aspects, Stylix theming, and SOPS-Nix secret management.

---

## 🌟 Highlights

- **Modular Architecture**: Composable system & user aspects managed with `den` and `import-tree`.
- **Dual-Profile Structure**:
  - **`muggy-nixos`**: Primary personalized desktop configuration (Gaming, AI tooling, Media, SOPS).
  - **`generic` / `default`**: Portable, out-of-the-box profile for any machine without hardware lock-in.
- **Developer & AI Tooling**: Native integration for Antigravity CLI, OpenCode, Claude Desktop / Code, Codex, Herdr, and OmniGraph.
- **Fast Deployments**: Optimized deployment workflow using `nh` (`nos` command) with visual diffs, and `nosw` to pre-build in the background on every save.
- **Checked**: `nix flake check` runs formatting (`alejandra`), dead code (`deadnix`), `statix`, and a syntax check of the Lua, JavaScript and shell kept in `files/`. A headless QEMU VM boots the real configuration to test changes without touching the live session.
- **Security & Privacy**: Secrets encrypted via Age/SOPS-Nix; AI workspace memories and sessions kept 100% local via `.gitignore`.

---

## 🚀 Quickstart & Installation

### Option 1: Install the Generic Template (New Machine / Other Users)

```sh
# 1. Clone the repository
git clone https://github.com/chandrahmuki/nixos-config.git ~/nixos-config
cd ~/nixos-config

# 2. Generate your machine's hardware configuration
sudo nixos-generate-config --show-hardware-config > hosts/system/hardware-configuration.nix

# 3. Check flake evaluation
nix flake check --no-build

# 4. Build and activate the generic configuration
sudo nixos-rebuild switch --flake .#generic
```

### Option 2: Daily Workflow (`muggy-nixos`)

Once installed, managing your system is fast and simple:

```sh
# Apply configuration changes
nos

# Update flake dependencies
nfu

# Pre-build on every save, so `nos` only has to activate
nosw
```

Checks and tests:

```sh
nix fmt                 # format every Nix file with alejandra
nix flake check         # format, dead code, statix, syntax of files/
scripts/vm-test.sh start   # boot the config headless (see the script header)
```

---

## ⚙️ Customization (`settings.nix`)

Identity, locale, timezone, and active aspect profiles are defined centrally. `settings.nix` is the public base; `hosts/<name>/settings.nix` extends it and only states what differs:

```nix
{
  username = "user";
  hostname = "nixos";
  system = "x86_64-linux";
  configDirectory = "/home/user/nixos-config";
  timeZone = "UTC";
  locale = "en_US.UTF-8";

  profiles = {
    desktop = [ "hyprland" "neovim" "terminal" "theme" "utils" ... ];
    user = [ "git" "xdg" "yazi" ... ];
    personalDesktop = [ "ai" "gaming" "media" ... ];
    personalUser = [ "discord" "herdr" "zen-browser" ... ];
  };
}
```

---

## 📁 Repository Layout

```text
nixos-config/
├── aspects/                  # Modular NixOS and Home Manager aspects
│   ├── ai.nix                # AI tools (Antigravity, Claude, OpenCode, OmniGraph)
│   ├── herdr.nix             # Herdr workspace manager
│   ├── media.nix             # MPV, YT-DLP, Cliamp & playlists
│   ├── nh.nix                # Nix Helper (nos command)
│   ├── sops.nix              # SOPS-Nix encrypted secret management
│   ├── terminal.nix          # Fish, Foot, Starship, Zoxide
│   └── ...
├── assets/                   # Radio configuration
├── files/                    # Lua, JavaScript and shell kept out of Nix strings
│   ├── hyprland/             # hyprland.lua and the muggy-theme, restart-quickshell, local-workspace scripts
│   └── chatgpt/              # ELF interpreter relocator for the ChatGPT package
├── hosts/
│   ├── muggy-nixos/          # Personal workstation: default.nix, settings, hardware, extra packages
│   └── system/               # Generic host: default.nix and a hardware template
├── lib/
│   └── mk-nixos-configuration.nix  # Builds a system from a host description
├── nvim/                     # Neovim configuration
├── quickshell/               # QML shell, linked out of the store for hot reload
├── scripts/                  # vm-test (headless VM), theme-selftest, update-codex
├── secrets/                  # Encrypted SOPS secrets (secrets.yaml)
├── wallpapers/               # Wallpapers used by Stylix and the shell
├── flake.nix                 # Flake inputs, outputs, formatter and checks
├── home.nix                  # Home Manager base
├── settings.nix              # Public base settings
└── statix.toml               # statix configuration
```

---

## 🔒 Secrets Management

Secrets are encrypted using [sops-nix](https://github.com/Mic92/sops-nix) with Age keys (`~/.ssh/id_ed25519`). Plaintext secrets never touch Git; only the encrypted `secrets.yaml` is tracked.

---

## 📄 License

[MIT License](LICENSE)
