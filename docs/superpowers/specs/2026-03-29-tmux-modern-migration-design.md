# Design Spec: tmux "Modern-Power" Migration (Tokyo Night)

## Context
The user wants to migrate from Zellij to tmux while maintaining a modern, aesthetic, and fluid experience. The setup must integrate perfectly with the existing **Tokyo Night Moon** theme and provide advanced features like session persistence and seamless navigation with Neovim.

## Goals
- Replace (or complement) Zellij with a highly customized tmux setup.
- Maintain **Alt + h/j/k/l** navigation across panes and Neovim.
- Ensure visual consistency with the Tokyo Night Moon theme.
- Provide session persistence (automatic save/restore).

## Architecture

### 1. NixOS Module (`modules/tmux.nix`)
The configuration will be managed via Home Manager's `programs.tmux`.

**Key Settings:**
- `enable = true`
- `shortcut = "b"` (Prefix: Ctrl-b)
- `baseIndex = 1`
- `escapeTime = 0` (Crucial for Neovim responsiveness)
- `mouse = true`
- `terminal = "tmux-256color"`

**Plugins:**
- `pkgs.tmuxPlugins.power-theme`: Using the Tokyo Night Moon color palette.
- `pkgs.tmuxPlugins.vim-tmux-navigator`: For seamless pane switching.
- `pkgs.tmuxPlugins.resurrect`: Session saving.
- `pkgs.tmuxPlugins.continuum`: Automatic session saving/restoring.
- `pkgs.tmuxPlugins.yank`: System clipboard integration.

**Custom Bindings:**
- `Alt + h/j/k/l`: Switch panes (compatible with Neovim).
- `Prefix + s`: Split horizontal.
- `Prefix + v`: Split vertical.
- `Prefix + r`: Source configuration file.

### 2. Neovim Integration (`nvim/lua/plugins/tmux.lua`)
A new plugin file will be created to handle the Neovim side of the navigation.
- Plugin: `christoomey/vim-tmux-navigator`.
- Mappings for `Alt + h/j/k/l` within Neovim.

### 3. Visual Design (Status Bar)
- **Left:** Session name, Mode indicator.
- **Center:** Window list with active styling.
- **Right:** Git branch (using a script or built-in helper), Date/Time.
- **Colors:** Deep blues (#1a1b26), purples, and cyans.

## Success Criteria
- [ ] `tmux` starts with a Tokyo Night theme.
- [ ] Navigation between tmux panes and Neovim panes works with a single `Alt + h/j/k/l` keypress.
- [ ] Sessions are automatically restored after a logout/reboot.
- [ ] System clipboard works for copy-pasting from tmux.

## Potential Constraints
- Conflict with existing `Alt` bindings in the terminal (unlikely given current Zellij config).
- Ensuring `zjstatus`-like branch detection in tmux (might require a small bash helper if the plugin doesn't handle it).
