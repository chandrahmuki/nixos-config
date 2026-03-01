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

### Global Configuration Refactoring
When the user chooses a custom hostname or username, the script should update all internal references:
1.  **Directory Renaming**: Move host-specific directories to match the new hostname.
2.  **Ad-hoc `sed` Updates**: Replace placeholder values across the codebase.
```bash
sed -i "s/$OLD_HOSTNAME/$NEW_HOSTNAME/g" "$SCRIPT_DIR/flake.nix"
sed -i "s/$OLD_HOSTNAME/$NEW_HOSTNAME/g" "$SCRIPT_DIR/modules/nh.nix"
```

## Idempotence and Safety
Bootstrap scripts should be safe to run multiple times.

### Directory Check before Move
Always verify the source directory exists before attempting a rename to avoid errors on subsequent runs:
```bash
if [ -d "$SCRIPT_DIR/hosts/$CONFIG_HOSTNAME" ]; then
    mv "$SCRIPT_DIR/hosts/$CONFIG_HOSTNAME" "$SCRIPT_DIR/hosts/$FINAL_HOSTNAME"
fi
```

### Build Verification with Ad-hoc Flags
Check if the configuration is valid using:
```bash
nix flake metadata . --extra-experimental-features 'nix-command flakes'
```

## Benefits
- **Zero-Manual-Config**: Users only need to clone the repo and run one script.
- **Consistent Environment**: Ensures the target hostname and hardware configuration are correctly set before the first reboot.
- **Improved UX**: Reduces the barrier to entry for complex flake-based systems.
