# Tmux "Modern-Power" Migration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Set up a modern tmux environment with Tokyo Night theme and seamless Neovim integration.

**Architecture:** A dedicated NixOS module for tmux, a Fish alias, and a Neovim plugin for navigation.

**Tech Stack:** NixOS, Home Manager, tmux, Neovim (Lua).

---

### Task 1: Create tmux Module

**Files:**
- Create: `modules/tmux.nix`

- [ ] **Step 1: Write `modules/tmux.nix`**

```nix
{ config, lib, pkgs, username, ... }:

{
  home-manager.users.${username} = { config, lib, ... }: {
    programs.tmux = {
      enable = true;
      shortcut = "b";
      baseIndex = 1;
      newSession = true;
      escapeTime = 0;
      mouse = true;
      keyMode = "vi";
      terminal = "tmux-256color";
      historyLimit = 10000;

      plugins = with pkgs.tmuxPlugins; [
        sensible
        yank
        {
          plugin = power-theme;
          extraConfig = ''
            set -g @tmux_power_theme 'moon'
            set -g @tmux_power_user_icon ''
            set -g @tmux_power_session_icon '󱂬'
          '';
        }
        {
          plugin = resurrect;
          extraConfig = ''
            set -g @resurrect-strategy-nvim 'session'
            set -g @resurrect-capture-pane-contents 'on'
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

      extraConfig = ''
        # Seamless navigation with Alt + h/j/k/l
        bind-key -n 'M-h' if-shell "$is_vim" 'send-keys M-h' 'select-pane -L'
        bind-key -n 'M-j' if-shell "$is_vim" 'send-keys M-j' 'select-pane -D'
        bind-key -n 'M-k' if-shell "$is_vim" 'send-keys M-k' 'select-pane -U'
        bind-key -n 'M-l' if-shell "$is_vim" 'send-keys M-l' 'select-pane -R'

        # Intuitive splits
        bind s split-window -v -c "#{pane_current_path}"
        bind v split-window -h -c "#{pane_current_path}"

        # Quick reload
        bind r source-file ~/.config/tmux/tmux.conf \; display "Config reloaded!"

        # Neovim detection
        is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
            | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'"
      '';
    };
  };
}
```

- [ ] **Step 2: Commit Task 1**

```bash
git add modules/tmux.nix
git commit -m "feat(tmux): add modern-power tmux module"
```

---

### Task 2: Activation and Alias

**Files:**
- Modify: `modules/default.nix`
- Modify: `modules/terminal.nix`

- [ ] **Step 1: Activate module in `modules/default.nix`**

```nix
# Find the imports list and add ./tmux.nix
```

- [ ] **Step 2: Add `tx` alias in `modules/terminal.nix`**

```nix
# In programs.fish.shellAliases
tx = "tmux attach || tmux new-session";
```

- [ ] **Step 3: Commit Task 2**

```bash
git add modules/default.nix modules/terminal.nix
git commit -m "feat(tmux): enable module and add tx alias"
```

---

### Task 3: Neovim Integration

**Files:**
- Create: `nvim/lua/plugins/tmux.lua`

- [ ] **Step 1: Create `nvim/lua/plugins/tmux.lua`**

```lua
return {
  "christoomey/vim-tmux-navigator",
  lazy = false,
  keys = {
    { "<A-h>", "<cmd>TmuxNavigateLeft<cr>", desc = "Window Left" },
    { "<A-j>", "<cmd>TmuxNavigateDown<cr>", desc = "Window Down" },
    { "<A-k>", "<cmd>TmuxNavigateUp<cr>", desc = "Window Up" },
    { "<A-l>", "<cmd>TmuxNavigateRight<cr>", desc = "Window Right" },
  },
}
```

- [ ] **Step 2: Commit Task 3**

```bash
git add nvim/lua/plugins/tmux.lua
git commit -m "feat(nvim): add vim-tmux-navigator for seamless navigation"
```

---

### Task 4: Validation

- [ ] **Step 1: Run NixOS build check**

```bash
nh os build . --hostname muggy-nixos
```

- [ ] **Step 2: Apply configuration**

```bash
nos
```
