# Design Spec: Zellij Session Persistence & Plugin Stabilization

**Date:** 2026-03-18
**Topic:** Fixing broken plugin links in long-running Zellij sessions after Nix garbage collection.

## Problem Statement
The current `modules/zellij.nix` uses direct Nix store paths for WASM plugins (`zjstatus` and `zellij-autolock`). When a Nix configuration is updated or garbage-collected, the old store paths are deleted. Long-running Zellij sessions that reference these paths crash or fail to reload plugins because the files are missing.

## Goal
Ensure Zellij plugins remain accessible to active sessions even after the Nix store is cleaned up, by using stable filesystem paths.

## Proposed Solution: Stable Symlinks
We will use Home Manager's `home.file` attribute to create symbolic links at fixed locations within the user's home directory. These links will always point to the current version of the plugin in the Nix store.

### 1. File Locations
Plugins will be symlinked to:
- `~/.config/zellij/plugins/zjstatus.wasm`
- `~/.config/zellij/plugins/zellij-autolock.wasm`

### 2. Configuration Changes
Update `modules/zellij.nix` to reference these stable paths instead of `${plugin_drv}`.

```nix
# Before:
path = "file:${zellij-autolock}";

# After:
path = "file:/home/david/.config/zellij/plugins/zellij-autolock.wasm";
```
*Note: We will use a dynamically constructed path based on `config.home.homeDirectory` to avoid hardcoding `/home/david`.*

### 3. Implementation Steps
1. Define plugin derivations (already done in `let` block).
2. Add `home.file` entries to map these derivations to `~/.config/zellij/plugins/`.
3. Update `programs.zellij.settings.plugins` to use the new paths.
4. Update `programs.zellij.layouts.dev` to use the new paths for `zjstatus`.

## Verification Plan
1. Apply the new configuration with `just switch`.
2. Verify that the symlinks exist: `ls -l ~/.config/zellij/plugins/`.
3. Start a Zellij session.
4. Run `nix-collect-garbage -d`.
5. Verify the session still functions and the symlink points to a valid (new) store path.
