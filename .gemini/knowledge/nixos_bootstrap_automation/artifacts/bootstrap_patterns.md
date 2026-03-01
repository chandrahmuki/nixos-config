# NixOS Bootstrap Automation

## Problem: Bootstrap Cold Start
On a fresh NixOS installation, experimental features like `flakes` and `nix-command` are usually disabled by default. Traditional methods require manually editing `/etc/nixos/configuration.nix` and running `nixos-rebuild switch` before being able to use a flake-based configuration.

## Solution: On-the-fly Feature Enabling
The `install.sh` script automates this by passing the required experimental features as ad-hoc flags to the `nix` and `nixos-rebuild` commands.

### Key Flags
Use `--extra-experimental-features 'nix-command flakes'` to bypass system-wide settings during the initial bootstrap.

## Advanced Personalization Patterns
Modern bootstrap scripts can handle system personalization without manual file intervention.

### Automated Detection & Safeguard
Detecting the current environment to suggest defaults, with a safeguard for generic install users (e.g., `nixos` on ISO):
```bash
DETECTED_USER=$(whoami)
if [ "$DETECTED_USER" == "nixos" ]; then
    # Force manual input for generic users
    read -p "Enter username: " FINAL_USER
else
    # Suggest detected user
    read -p "Use '$DETECTED_USER'? (Y/n): " -n 1 -r
fi
```

### Declarative Global Configuration (Modern Approach)
Instead of using `sed` across multiple files to update hardcoded hostnames and usernames, the modern approach uses centralized variables in `flake.nix`.
The bootstrap script updates ONLY these centralized variables:
```bash
# Update flake.nix using sed (one-stop shop)
sed -i "s/username = \".*\";/username = \"$FINAL_USERNAME\";/" "$SCRIPT_DIR/flake.nix"
sed -i "s/hostname = \".*\";/hostname = \"$FINAL_HOSTNAME\";/" "$SCRIPT_DIR/flake.nix"
```
These variables are then passed downstream to all modules via `specialArgs` and `extraSpecialArgs`, making the configuration truly declarative and resilient.

## Idempotence and Safety
Bootstrap scripts should be safe to run multiple times.

### Build Verification with Ad-hoc Flags
Check if the configuration is valid using:
```bash
nix flake metadata . --extra-experimental-features 'nix-command flakes'
```

## Benefits
- **Zero-Manual-Config**: Users only need to clone the repo and run one script.
- **Declarative Purity**: Avoids brittle search-and-replace across the codebase.
- **Consistent Environment**: Ensures the target hostname and hardware configuration are correctly set before the first reboot.
- **Improved UX**: Reduces the barrier to entry for complex flake-based systems.
