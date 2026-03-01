# Antigravity IDE Setup & Configuration

## LSP & Formatting
- **Language Server**: `nil` installed and configured with absolute store path in `settings.json`.
- **Formatter**: `nixfmt` (official) used via `jnoortheen.nix-ide`.
- **Extensions**: Symlinked from Nix store using full IDs:
  - `bbenoist.Nix-1.0.1-universal`
  - `jnoortheen.nix-ide-0.5.5-universal`
  - `enkia.tokyo-night` (UI Theme)

## UI & Theming
- **Color Theme**: "Tokyo Night" is applied globally via `workbench.colorTheme` in the mutable `.agent/antigravity-settings.json`.
- **Installation**: The extension is declared in `modules/antigravity.nix` in the `nixExtensions` array.

## Configuration Management
- **Settings File**: `antigravity-settings.json` is used as a mutable config file.
- **Symlink**: Managed via a Home Manager activation script (`linkAntigravitySettings`) to ensure the file remains writable by the agent while being symlinked to `~/.config/Antigravity/User/settings.json`.
- **MCP Config**: The `mcp_config.json` is symlinked from the module directory to `~/.gemini/antigravity/mcp_config.json`.

## Agent Policies (Turbo Mode)
Configured for maximum autonomy and speed:
- `autoExecutionPolicy`: `Turbo` (automatic execution of 'turbo' annotated steps).
- `reviewPolicy`: `Always Proceed` (reduces interactive friction).
- `confirmShellCommands`: `false`.

## SSH & Git
- **Key Recovery**: Keys recovered from old disk at `/run/media/david/root/home/david/.ssh`.
- **Git Config**: Remote URL switched to SSH (`git@github.com:chandrahmuki/nixos-config.git`) to utilize keys.
