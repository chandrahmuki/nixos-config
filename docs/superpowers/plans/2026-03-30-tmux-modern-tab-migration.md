# Tmux Modern-Tab Migration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Transform Tmux into a modern "Tab-centric" interface using Tokyo Night theme and high-performance navigation.

**Architecture:** Update the Home Manager configuration for Tmux by swapping the theme, adding navigation plugins, and moving the status bar to the top with browser-like keybindings.

**Tech Stack:** NixOS, Home Manager, Tmux, Tokyo Night Theme, fzf.

---

### Task 1: Update Plugins and UI Configuration

**Files:**
- Modify: `modules/tmux.nix`

- [ ] **Step 1: Replace theme and add new plugins**

Update the `plugins` list in `modules/tmux.nix`:
```nix
      plugins = with pkgs.tmuxPlugins; [
        sensible
        yank
        tokyo-night-tmux # New Theme
        tmux-sessionx    # Fuzzy Finder
        tmux-fzf         # Management Menu
        {
          plugin = resurrect;
          extraConfig = ''
            set -g @resurrect-strategy-nvim 'session'
            set -g @resurrect-capture-pane-contents 'on'
            set -g @resurrect-dir '~/.config/tmux/resurrect'
            set -g @resurrect-save-on-exit 'on'
          '';
        }
        {
          plugin = continuum;
          extraConfig = ''
            set -g @continuum-restore 'on'
            set -g @continuum-save-interval '5'
          '';
        }
        vim-tmux-navigator
      ];
```

- [ ] **Step 2: Add Tokyo Night specific configuration**

Add theme settings at the top of `extraConfig`:
```tmux
        # Theme Tokyo Night
        set -g @tokyo-night-tmux_window_id_style digital
        set -g @tokyo-night-tmux_pane_id_style hircut
        set -g @tokyo-night-tmux_show_datetime 0
        set -g @tokyo-night-tmux_show_path 1
        set -g @tokyo-night-tmux_path_format relative
        set -g @tokyo-night-tmux_show_battery_widget 1
```

- [ ] **Step 3: Move status bar to top**

In `extraConfig`:
```tmux
        set -g status-position top
```

- [ ] **Step 4: Commit UI changes**

```bash
git add modules/tmux.nix
git commit -m "feat(tmux): move status bar to top and switch to tokyo-night theme"
```

---

### Task 2: Configure Tab-First Keybindings

**Files:**
- Modify: `modules/tmux.nix`

- [ ] **Step 1: Add browser-like tab navigation**

Append to `extraConfig`:
```tmux
        # Navigation rapide par onglets (Tabs) avec Alt
        bind -n M-1 select-window -t 1
        bind -n M-2 select-window -t 2
        bind -n M-3 select-window -t 3
        bind -n M-4 select-window -t 4
        bind -n M-5 select-window -t 5
        bind -n M-6 select-window -t 6
        bind -n M-7 select-window -t 7
        bind -n M-8 select-window -t 8
        bind -n M-9 select-window -t 9

        # Gestion des onglets
        bind -n M-n new-window -c "#{pane_current_path}"
        bind -n M-w kill-window
        bind -n M-Left previous-window
        bind -n M-Right next-window
```

- [ ] **Step 2: Configure tmux-sessionx keybind**

Append to `extraConfig`:
```tmux
        # SessionX : Fuzzy Finder Alt + s
        set -g @sessionx-bind 's'
        # On bind aussi sur Alt+s directement via tmux
        bind -n M-s run-shell "tmux-sessionx" 
```

- [ ] **Step 3: Commit navigation changes**

```bash
git add modules/tmux.nix
git commit -m "feat(tmux): add browser-like tab navigation and sessionx bind"
```

---

### Task 3: Final Validation and Cleanup

**Files:**
- Modify: `modules/tmux.nix`

- [ ] **Step 1: Remove legacy power-theme comments/code**

Ensure no references to `power-theme` remain in `modules/tmux.nix`.

- [ ] **Step 2: Apply configuration**

Run: `nos`
Expected: NixOS build succeeds and Tmux reloads.

- [ ] **Step 3: Verify UI**

Launch Tmux (`tx`) and verify:
1. Status bar is at the top.
2. Tokyo Night theme is active.
3. `Alt + n` creates a new tab.
4. `Alt + s` opens the fuzzy finder.

- [ ] **Step 4: Final Commit**

```bash
git commit -m "chore(tmux): cleanup legacy theme config and final validation"
```
