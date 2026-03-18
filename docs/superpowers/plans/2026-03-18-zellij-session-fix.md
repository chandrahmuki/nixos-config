# Zellij Session Persistence Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix broken plugin links in long-running Zellij sessions by using stable symlinks instead of direct Nix store paths.

**Architecture:** We will use Home Manager's `home.file` to create stable symlinks at `~/.config/zellij/plugins/*.wasm` and update Zellij configuration and layouts to reference these stable paths.

**Tech Stack:** Nix, Home Manager, Zellij.

---

### Task 1: Research and Validation

**Files:**
- Modify: `modules/zellij.nix`

- [ ] **Step 1: Verify current plugin URLs and SHAs**

Verify the current `zjstatus` and `zellij-autolock` versions in `modules/zellij.nix` are correct.

- [ ] **Step 2: Commit initial state**

```bash
git add modules/zellij.nix
git commit -m "chore: baseline for zellij session fix"
```

### Task 2: Implement Stable Symlinks

**Files:**
- Modify: `modules/zellij.nix`

- [ ] **Step 1: Add `home.file` configuration**

Add the `home.file` block to `modules/zellij.nix` to create symlinks for the WASM plugins.

```nix
{ config, pkgs, ... }:
# ...
{
  home.file.".config/zellij/plugins/zjstatus.wasm".source = zjstatus;
  home.file.".config/zellij/plugins/zellij-autolock.wasm".source = zellij-autolock;
  # ...
}
```

- [ ] **Step 2: Update plugin paths in `settings`**

Change the plugin path for `autolock` to use the stable filesystem path.

```nix
# In programs.zellij.settings.plugins
autolock = {
  path = "file:${config.home.homeDirectory}/.config/zellij/plugins/zellij-autolock.wasm";
  is_enabled = true;
};
```

- [ ] **Step 3: Update plugin paths in `layouts`**

Change the `location` for `zjstatus` in the `dev` layout.

```nix
# In programs.zellij.layouts.dev
plugin location="file:${config.home.homeDirectory}/.config/zellij/plugins/zjstatus.wasm" {
  # ...
}
```

- [ ] **Step 4: Commit changes**

```bash
git add modules/zellij.nix
git commit -m "feat(zellij): use stable symlinks for WASM plugins"
```

### Task 3: Verification and Deployment

**Files:**
- Run: `just switch`

- [ ] **Step 1: Apply configuration**

Run `just switch` (or `nos`) to apply the changes.

- [ ] **Step 2: Verify symlinks**

Run: `ls -l ~/.config/zellij/plugins/`
Expected: Two symlinks pointing to `/nix/store/...`

- [ ] **Step 3: Verify Zellij functionality**

Launch `zelldev` and verify that the status bar and autolock plugin still work correctly.

- [ ] **Step 4: Final commit and cleanup**

```bash
git status
# Ensure everything is clean
```
