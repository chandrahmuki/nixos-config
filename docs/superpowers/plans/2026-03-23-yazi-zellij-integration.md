# Unified Navigation Yazi + Zellij Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Integrate Yazi as a persistent sidebar in the Zellij `dev` layout and remove redundant internal explorers from Neovim to unify navigation via `Alt + hjkl`.

**Architecture:** 
1. Modify the NixOS Zellij module to update the `dev` layout with a Yazi pane.
2. Update Neovim configuration to disable/redirect internal explorer keybindings.
3. Align WhichKey documentation with the new workflow.

**Tech Stack:** Nix (NixOS/Home Manager), Lua (Neovim), Zellij, Yazi.

---

### Task 1: Update Zellij Layout

**Files:**
- Modify: `modules/zellij.nix`

- [ ] **Step 1: Update the `dev` layout in `modules/zellij.nix`**

Modify the `tab name="Editor"` section to include Yazi:
```nix
tab name="Editor" focus=true {
    pane split_direction="vertical" {
        pane size="15%" name="Files" command="yazi"
        pane name="Editor" focus=true command="nvim" {
            args "."
            start_suspended false
        }
        pane size="25%" {
            pane name="Gemini CLI" command="gemini" {
                start_suspended false
            }
            pane name="Terminal"
        }
    }
}
```

- [ ] **Step 2: Verify Nix syntax**
Run: `nix-instantiate --parse modules/zellij.nix > /dev/null`
Expected: Success (no output).

- [ ] **Step 3: Commit Zellij changes**
```bash
git add modules/zellij.nix
git commit -m "feat(zellij): add yazi sidebar to dev layout"
```

---

### Task 2: Clean up Neovim Explorer Keymaps

**Files:**
- Modify: `nvim/lua/plugins/snacks.lua`

- [ ] **Step 1: Remove/Redirect explorer keymaps**
Modify `nvim/lua/plugins/snacks.lua`:
- Remove `<leader>.` -> `Snacks.explorer()`
- Remove `<leader>e` -> `Snacks.explorer()`
- Remove `<leader>fe` -> `Snacks.explorer()`
- Ensure `<leader><space>` still points to `Snacks.picker.smart()` (for quick file search).

- [ ] **Step 2: Commit Neovim changes**
```bash
git add nvim/lua/plugins/snacks.lua
git commit -m "refactor(nvim): remove internal explorer keymaps in favor of yazi"
```

---

### Task 3: Update WhichKey Documentation

**Files:**
- Modify: `nvim/lua/plugins/whichkey.lua`

- [ ] **Step 1: Update labels in `nvim/lua/plugins/whichkey.lua`**
Remove or update labels for `<leader>e` and `<leader>.` if they were explicitly defined.
- Update `{ "<leader>e", icon = "󰙅 " }` to something else or remove it.
- Update `{ "<leader>.", icon = "󰉋 " }` to something else or remove it.

- [ ] **Step 2: Commit WhichKey changes**
```bash
git add nvim/lua/plugins/whichkey.lua
git commit -m "docs(nvim): update which-key labels for explorer"
```

---

### Task 4: Final Validation

- [ ] **Step 1: Apply configuration (Dry run or User check)**
Explain to the user how to apply: `nos` (as per memories) or `sudo nixos-rebuild switch`.
*Note: Since I cannot run `sudo`, I will ask the user to test the layout.*

- [ ] **Step 2: Verify Navigation**
1. Open Zellij with `zelldev`.
2. Check if Yazi is on the left.
3. Check if `Alt + h/l` moves between Yazi and Neovim.
4. Check if `<leader>e` in Neovim no longer opens the internal explorer.
