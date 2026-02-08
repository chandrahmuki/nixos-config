# ❄️ NixOS Configuration (Muggy-NixOS)

A high-performance, modern NixOS configuration featuring **Niri** (Wayland compositor) and **GNOME** (as a robust fallback), optimized for gaming and productivity.

![Desktop Screenshot](https://github.com/user-attachments/assets/0ed74bc7-cd22-45a3-86f3-e17897266439)

## ✨ Key Features
- **UI/UX**: [Niri](https://github.com/YaLTeR/niri) (unstable) with a custom [Noctalia shell](https://github.com/Noctatia/noctalia) setup.
- **Kernel**: Optimized CachyOS Bore kernel for low-latency desktop performance.
- **Gaming**: Pre-configured Steam, GameMode, and AMD GPU optimizations.
- **Shell**: Fish shell equipped with Atuin (SQLite history) and Zoxide (smart navigation).
- **Tools**: Ghostty terminal, VSCode/Antigravity, and declarative Brave/Chromium policy management.
- **Portability**: Completely decoupled username and home paths for easy adoption.

---

## 🚀 Installation Guide

> [!NOTE]
> This guide is designed for a fresh NixOS installation. The script handles hardware configuration and enabling Flakes automatically.

### 2. Run the Installation Script
The `install.sh` script will automate everything for you (username detection, hardware configuration, and the first system build):
```bash
chmod +x install.sh
./install.sh
```

**What the script does:**
0.  **Personalization**: Automatically detects your username and prompts for your desired hostname, updating `flake.nix` and renaming host directories accordingly.
1.  **Hardware**: Generates a `hardware-configuration.nix` for your specific machine.
2.  **Flakes**: Ensures Flakes are supported for the initial build.
3.  **Hostname**: Sets your system hostname to your chosen value.
4.  **Build**: Performs the initial `nixos-rebuild switch`.

### 4. Final Steps
After the script finishes, **reboot** your system:
```bash
sudo reboot
```

---

## 🛠️ Maintenance & Common Commands

This config uses [**nh**](https://github.com/viperML/nh) for a faster and cleaner NixOS experience.

- **Apply changes**: `nos` (a built-in alias for `nh os switch`)
- **Update system**: `nix flake update` (then run `nos`)
- **Cleanup**: `nh clean all`

## 📁 Project Structure
- `hosts/`: Host-specific configurations (hostname: `muggy-nixos`).
- `modules/`: Reusable components (Brave, Shell, Gaming, etc.).
- `home.nix`: Main Home-Manager user configuration.
- `docs/`: Detailed guides for specific components (Brave extensions, Triple Relay workflow).

---
*Maintained by chandrahmuki. Built with ❄️ and Antigravity AI.*
