# Fix IRC Module — Weechat Auto-Connect Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix the Weechat IRC module so Rizon auto-connects and joins #kanadi on startup.

**Architecture:** Replace the fragile Python setup script + declarative config approach with startup commands via Weechat's `weechat.startup.command_before_plugins` and `command_after_plugins` options in `weechat.conf`. These are the only config options Weechat reliably respects from flat files. The server config itself is managed by `/server add` commands at first launch via a one-shot startup script. After first run, `autoconnect on` handles everything.

**Tech Stack:** NixOS HM, Weechat 4.8.2, xdg.configFile

---

## Root Cause Analysis

1. **Weechat 4 config format** — `[server.rizon]` is invalid syntax. Weechat 4 uses `[server]` section with `rizon.xxx` option prefixes, and the config version is 5. Writing declarative `irc.conf` files is fragile and error-prone.
2. **Python setup script issues** — The `/server add` command got a wrong address (`"rizon"` instead of `"irc.rizon.net/6697"`), created a duplicate `irc.rizon.net` server, and `/script remove` doesn't work for autoload scripts.
3. **Weechat ignores non-standard sections** in config files — `[server_default]` was silently ignored too.

## Strategy

Use `weechat.conf` startup commands to run `/server add` and config commands once. This is the only reliable declarative mechanism in Weechat. Remove all irc.conf/xfer.conf and the Python setup script — they are all broken.

---

### Task 1: Clean up broken state in ~/.config/weechat

**Files:** None (manual cleanup)

- [ ] **Step 1: Remove broken config and state files**

Run these commands in the user's shell:

```bash
# Remove broken Weechat config files that HM wrote
rm -f ~/.config/weechat/irc.conf ~/.config/weechat/xfer.conf ~/.config/weechat/weechat.conf

# Remove the broken Python setup script
rm -f ~/.config/weechat/python/autoload/setup_rizon.py

# Remove the flag file
rm -f ~/.local/share/weechat/setup_rizon_done

# Remove stale server configs that Weechat generated from the broken script
# (These live inside irc.conf which we already removed, so this step is done)
```

- [ ] **Step 2: Verify cleanup**

Run: `ls ~/.config/weechat/ 2>/dev/null`
Expected: Empty or no config files for irc.conf, xfer.conf, weechat.conf, setup_rizon.py

---

### Task 2: Rewrite irc.nix with startup commands approach

**Files:**
- Modify: `modules/irc.nix`

- [ ] **Step 1: Replace the entire module content**

The new approach:
- Install weechat + scripts via home.packages and home.file (keep existing)
- Use `xdg.configFile."weechat/weechat.conf"` with `force = true` to set startup commands
- The startup commands add the server on first run, then clear themselves
- Scripts (xdccq, autojoin, autoconnect) go in `~/.local/share/weechat/python/` (not autoload — user loads them manually or we symlink to autoload/)
- xdg.userDirs for download dir
- home.file for manga/.keep

Replace entire `modules/irc.nix` content with:

```nix
{
  config,
  lib,
  pkgs,
  username,
  inputs,
  ...
}:
{
  home-manager.users.${username} =
    {
      config,
      lib,
      ...
    }:
    {
      home.packages = [
        pkgs.weechat
      ];

      xdg.configFile."weechat/weechat.conf" = {
        force = true;
        text = ''
          [startup]
          command_after_plugins = "/server add rizon irc.rizon.net/6697 -tls;/set irc.server.rizon.autoconnect on;/set irc.server.rizon.autojoin #kanadi;/set irc.server.rizon.nicks ${username};/set irc.server.rizon.username ${username};/set irc.server.rizon.realname ${username};/set xfer.file.download_directory ~/Downloads/manga;/connect rizon;/save;/set weechat.startup.command_after_plugins ""
        '';
      };

      xdg.userDirs = {
        download = "${config.home.homeDirectory}/Downloads";
      };

      home.file."Downloads/manga/.keep" = {
        text = "";
        force = true;
      };

      home.file."${config.home.homeDirectory}/.local/share/weechat/python/xdccq.py" = {
        source = pkgs.fetchurl {
          url = "https://weechat.org/files/scripts/xdccq.py";
          sha256 = "1qshy6bdw2ypwlaylfdn2j90ib0jv90myf8is4g3qamwwq2famas";
        };
        executable = true;
      };

      home.file."${config.home.homeDirectory}/.local/share/weechat/python/autojoin.py" = {
        source = pkgs.fetchurl {
          url = "https://weechat.org/files/scripts/autojoin.py";
          sha256 = "10y71ciiankinwi83b19fj8452vxgi1hasnwca64l0lrjgmbnrai";
        };
        executable = true;
      };

      home.file."${config.home.homeDirectory}/.local/share/weechat/python/autoconnect.py" = {
        source = pkgs.fetchurl {
          url = "https://weechat.org/files/scripts/autoconnect.py";
          sha256 = "1va0k8304kqkv2jxkrhrfbq347pcf04fp8jwqwqz4qw2xb5zxv3m";
        };
        executable = true;
      };
    };
}
```

- [ ] **Step 2: Validate syntax**

Run: `nix eval .#nixosConfigurations.muggy-nixos.config.home-manager.users.david.home.stateVersion`
Expected: `"25.11"` without errors

- [ ] **Step 3: Commit**

```bash
git add modules/irc.nix
git commit -m "fix(irc): use startup commands for server setup instead of broken config files"
```

---

### Task 3: Deploy and manually test

**Files:** None

- [ ] **Step 1: Clean existing Weechat state**

```bash
rm -rf ~/.config/weechat/ ~/.local/share/weechat/
```

- [ ] **Step 2: Deploy**

Run: `sudo nh os switch`

- [ ] **Step 3: Launch Weechat and verify**

Run: `weechat`

Expected behavior:
1. Weechat starts with no errors about config
2. After 1-2 seconds, Rizon server is added
3. Auto-connects to Rizon
4. Auto-joins #kanadi
5. XDCC download dir is ~/Downloads/manga

Verify in Weechat:
- `/server` — shows `rizon` with address `irc.rizon.net/6697`
- `/channel` — shows `#kanadi` 
- `/set xfer.file.download_directory` — shows `~/Downloads/manga`

- [ ] **Step 4: Verify scripts are available**

In Weechat: `/script list`
Expected: xdccq, autojoin, autoconnect listed (may need `/script load xdccq` etc.)

- [ ] **Step 5: Verify startup command cleared itself**

In Weechat: `/set weechat.startup.command_after_plugins`
Expected: empty string (the command cleared itself after running)

---

### Task 4: Handle edge case — startup command runs every launch

**Files:**
- Modify: `modules/irc.nix` (if needed)

The startup command in Task 2 ends with `/set weechat.startup.command_after_plugins ""` which clears itself after the first run. However, `weechat.conf` has `force = true` so HM will overwrite it on every deploy. This means:

- On first Weechat launch → command runs, adds server, clears itself via `/save` + `/set`
- On subsequent launches → `command_after_plugins` is empty because Weechat saved the empty value
- On redeploy (after `nos`) → HM writes the commands again because `force = true`, but `/server add rizon` will fail harmlessly ("server already exists") and the server settings are already correct

This is acceptable behavior. The `/server add` command on an existing server just shows a warning and continues. No broken state.

- [ ] **Step 1: Test redeploy scenario**

After confirming Weechat works (Task 3):
1. Run `sudo nh os switch` again
2. Launch `weechat`
3. Verify no errors and Rizon still connects

---

### Task 5: Load scripts automatically via autoload

**Files:**
- Modify: `modules/irc.nix`

Scripts are installed to `~/.local/share/weechat/python/` but Weechat only auto-loads scripts from `~/.local/share/weechat/python/autoload/`. We need to symlink them.

- [ ] **Step 1: Add autoload symlinks for scripts**

Add to the module (inside `home-manager.users.${username}` block):

```nix
      home.file."${config.home.homeDirectory}/.local/share/weechat/python/autoload/xdccq.py".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.local/share/weechat/python/xdccq.py";

      home.file."${config.home.homeDirectory}/.local/share/weechat/python/autoload/autojoin.py".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.local/share/weechat/python/autojoin.py";

      home.file."${config.home.homeDirectory}/.local/share/weechat/python/autoload/autoconnect.py".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.local/share/weechat/python/autoconnect.py";
```

- [ ] **Step 2: Validate syntax**

Run: `nix eval .#nixosConfigurations.muggy-nixos.config.home-manager.users.david.home.stateVersion`
Expected: `"25.11"`

- [ ] **Step 3: Commit**

```bash
git add modules/irc.nix
git commit -m "feat(irc): auto-load scripts via autoload symlinks"
```

---

### Task 6: Final lint and verification

**Files:** None

- [ ] **Step 1: Run alejandra**

Run: `alejandra --check modules/irc.nix`
Expected: No output (valid)

- [ ] **Step 2: Run deadnix**

Run: `deadnix --check modules/irc.nix`
Expected: No warnings

- [ ] **Step 3: Run statix**

Run: `statix check modules/irc.nix`
Expected: No errors

- [ ] **Step 4: Commit any fixes**

```bash
git add modules/irc.nix
git commit -m "style(irc): fix linting issues"
```