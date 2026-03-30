# Design Spec: Tmux Modern-Tab Migration (Tokyo Night)

## 1. Goal
Transform the current Tmux setup into a modern, "Tab-centric" interface inspired by Niri and browsers, using the Tokyo Night theme and high-performance navigation plugins.

## 2. Interface (UI)
- **Position**: Move the status bar to the top (`status-position top`).
- **Theme**: Switch to `tokyo-night-tmux` plugin.
  - Transparent/Dark background matching Neovim.
  - Active tab highlighting.
  - Nerd Font icons enabled for window/tab names.
- **Widgets**: Date, time, and session name displayed on the right.

## 3. Navigation & Management (Plugins)
- **tmux-sessionx**: Fuzzy finder for sessions and windows.
  - Keybind: `Alt + s`.
- **tmux-fzf**: Command menu for advanced management.
  - Keybind: `Prefix + F`.
- **tmux-resurrect/continuum**: Retained for persistence.

## 4. Keybindings (Tab-First Workflow)
- **Switch Tabs**: `Alt + 1-9`.
- **New Tab**: `Alt + n`.
- **Close Tab**: `Alt + w`.
- **Next/Prev Tab**: `Alt + Left/Right`.
- **Integration**: Keep `Alt + h/j/k/l` for seamless pane/Vim navigation.

## 5. Implementation Plan
1. Update `modules/tmux.nix` to include new plugins and theme configuration.
2. Configure `extraConfig` for top-bar position and browser-like keybindings.
3. Clean up legacy `power-theme` configuration.
4. Run `nos` to apply changes.
