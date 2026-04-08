# NixOS Codebase Rearchitecture Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Clean, restructure, and optimize the NixOS config by removing dead code, fixing inconsistencies, deduplicating packages, standardizing conventions, and consolidating modules into logical groups.

**Architecture:** Incremental phased approach. Each phase is independently testable with `nix flake check` + `nos`. Rollback available via `nos --rollback` if anything breaks. Phases are ordered from lowest risk (deletions) to highest risk (restructuring).

**Tech Stack:** NixOS flake, Home Manager as NixOS module, sops-nix, niri, walker

---

## Phase 1: Dead Files & Deletions (ZERO RISK)

### Task 1.1: Remove screenshot from repo

**Files:**
- Remove: `Screenshot from 2026-04-06 10-25-43.png`
- Modify: `.gitignore`

- [ ] **Step 1: Add screenshot pattern to .gitignore**

Add to `.gitignore` under the `# --- APP SPECIFIC ---` section:
```
*.png
*.jpg
*.jpeg
```

- [ ] **Step 2: Remove the screenshot from git tracking**

```bash
git rm "Screenshot from 2026-04-06 10-25-43.png"
```

- [ ] **Step 3: Verify `nix flake check` still passes**

Run: `nix flake check`
Expected: PASS (evaluation warnings about neovim are OK at this stage)

- [ ] **Step 4: Commit**

```bash
git add .gitignore
git commit -m "chore: remove stray screenshot and add image patterns to gitignore"
```

### Task 1.2: Remove result symlink

**Files:**
- Remove: `result` (symlink)

- [ ] **Step 1: Add result symlink to .gitignore (it should already be there)**

Check `.gitignore` already has `result` and `result-*` entries. If yes, proceed. The symlink is likely not tracked by git but verify:

```bash
git ls-files result
```

If empty, it's already gitignored. If tracked, `git rm result`.

- [ ] **Step 2: Delete the symlink**

```bash
rm result
```

- [ ] **Step 3: Commit (if changes were needed)**

```bash
git commit -m "chore: ensure result symlink is gitignored"
```

### Task 1.3: Remove .ruff_cache from repo

**Files:**
- Remove: `.ruff_cache/` directory
- Modify: `.gitignore`

- [ ] **Step 1: Add ruff cache to .gitignore**

Add under `# --- NIX & BUILD ---`:
```
.ruff_cache/
```

- [ ] **Step 2: Remove ruff_cache from git tracking**

```bash
git rm -r --cached .ruff_cache/
rm -rf .ruff_cache/
```

- [ ] **Step 3: Verify and commit**

```bash
nix flake check
git add .gitignore
git commit -m "chore: remove .ruff_cache and add to gitignore"
```

### Task 1.4: Delete antigravity module + custom package

**Files:**
- Remove: `modules/antigravity.nix`
- Remove: `pkgs/google-antigravity/` (entire directory)
- Modify: `overlays.nix` (remove google-antigravity overlay)
- Modify: `modules/theme.nix` (remove antigravity icon symlinks)
- Modify: `modules/claude.nix` (fix MCP github token path)

- [ ] **Step 1: Remove antigravity module**

```bash
rm modules/antigravity.nix
```

- [ ] **Step 2: Remove custom package**

```bash
rm -rf pkgs/google-antigravity/
```

- [ ] **Step 3: Remove overlay entry in overlays.nix**

Edit `overlays.nix` — remove the line `google-antigravity = final.callPackage ./pkgs/google-antigravity { };` and its comment. Result:

```nix
{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{
  nixpkgs.overlays = [
    inputs.niri.overlays.niri
    inputs.opencode.overlays.default
    (final: prev: {
      deno = prev.deno.overrideAttrs (_: {
        doCheck = false;
      });
    })
  ];
}
```

- [ ] **Step 4: Remove antigravity icon symlinks from theme.nix**

Remove lines 33-39 from `modules/theme.nix` (the two `home.file` entries for antigravity SVG icon and LACT icon — actually keep the LACT one, only remove the antigravity one):

```nix
# DELETE these lines:
home.file.".local/share/icons/hicolor/scalable/apps/io.github.ilya_zlobintsev.LACT.svg".source =
  "${pkgs.lact}/share/pixmaps/io.github.ilya_zlobintsev.LACT.svg";

home.file.".local/share/icons/hicolor/scalable/apps/antigravity.svg".source = "${
  pkgs.antigravity-unwrapped or pkgs.antigravity
}/share/icons/hicolor/scalable/apps/antigravity.svg";
```

Actually — keep the LACT icon line, it's unrelated. Only remove the antigravity.svg symlink block (lines 37-39).

- [ ] **Step 5: Fix claude.nix MCP token path**

In `modules/claude.nix`, the MCP github command reads from `~/.config/antigravity/github_token` but the sops secret is `github_token` at `~/.config/sops/github_token`. Fix line 37:

Change:
```
"GITHUB_TOKEN=$(cat ~/.config/antigravity/github_token) npx -y @modelcontextprotocol/server-github"
```
To:
```
"GITHUB_TOKEN=$(cat ~/.config/sops/github_token) npx -y @modelcontextprotocol/server-github"
```

- [ ] **Step 6: Verify and commit**

```bash
nix flake check
git add -A
git commit -m "chore: remove antigravity module, package, and references"
```

### Task 1.5: Delete tmux module

**Files:**
- Remove: `modules/tmux.nix`

- [ ] **Step 1: Remove tmux module**

```bash
rm modules/tmux.nix
```

- [ ] **Step 2: Verify and commit**

```bash
nix flake check
git add -A
git commit -m "chore: remove tmux module (replaced by zellij)"
```

### Task 1.6: Remove stale templates and generated files

**Files:**
- Remove: `templates/fuzzel.conf` (fuzzel is disabled)
- Remove: `templates/mako.conf` (mako is managed by matugen symlink)
- Remove: `generated/fuzzel.ini` (unused)

Keep: `templates/matugen.toml` (used by utils.nix `upc` function), `templates/yazi.conf` (may be referenced), `generated/mako` (symlinked from notifications.nix), `generated/noctalia-settings.json`, `generated/yazi.toml`

- [ ] **Step 1: Remove stale template files**

```bash
rm templates/fuzzel.conf
rm templates/mako.conf
rm generated/fuzzel.ini
```

- [ ] **Step 2: Verify and commit**

```bash
nix flake check
git add -A
git commit -m "chore: remove stale fuzzel and mako templates"
```

---

## Phase 2: Deduplication & Bug Fixes (LOW RISK)

### Task 2.1: Fix duplicate jq package

**Files:**
- Modify: `modules/niri.nix` (remove `pkgs.jq` from home.packages)
- `jq` remains in `modules/utils.nix:20`

- [ ] **Step 1: Remove jq from niri.nix**

In `modules/niri.nix`, remove lines 19-20:
```nix
    # jq est nécessaire pour certains scripts niri
    home.packages = [ pkgs.jq ];
```

- [ ] **Step 2: Verify and commit**

```bash
nix flake check
git add modules/niri.nix
git commit -m "fix: remove duplicate jq package (already in utils.nix)"
```

### Task 2.2: Fix duplicate nodejs package

**Files:**
- Modify: `modules/gemini.nix` (remove `pkgs.nodejs` from home.packages — already in utils.nix)

- [ ] **Step 1: Remove nodejs from gemini.nix**

In `modules/gemini.nix`, change line 33-37 from:
```nix
      home.packages = [
        pkgs.gemini-cli
        pkgs.nodejs
        pkgs.go
      ];
```
To:
```nix
      home.packages = [
        pkgs.gemini-cli
        pkgs.go
      ];
```

- [ ] **Step 2: Verify and commit**

```bash
nix flake check
git add modules/gemini.nix
git commit -m "fix: remove duplicate nodejs (already in utils.nix)"
```

### Task 2.3: Fix duplicate python3 package

**Files:**
- Modify: `modules/neovim.nix` (remove `python3` from extraPackages — already in utils.nix)

- [ ] **Step 1: Remove python3 from neovim.nix**

In `modules/neovim.nix`, remove the line `python3` from the `extraPackages` list (line 26).

- [ ] **Step 2: Verify and commit**

```bash
nix flake check
git add modules/neovim.nix
git commit -m "fix: remove duplicate python3 (already in utils.nix)"
```

### Task 2.4: Fix duplicate programs.gamemode.enable

**Files:**
- Modify: `hosts/system/default.nix` (remove `programs.gamemode.enable = true;` from line 245 — it's also in steam.nix)

- [ ] **Step 1: Remove duplicate gamemode enable from default.nix**

In `hosts/system/default.nix`, remove line 245:
```nix
  programs.gamemode.enable = true;
```

(Since it's already fully configured with settings in `modules/steam.nix:31-50`.)

- [ ] **Step 2: Verify and commit**

```bash
nix flake check
git add hosts/system/default.nix
git commit -m "fix: remove duplicate gamemode enable (configured in steam.nix)"
```

### Task 2.5: Fix duplicate hardware.graphics.enable

**Files:**
- Modify: `modules/performance-tuning.nix` (remove `hardware.graphics.enable = true;` — already in default.nix)

- [ ] **Step 1: Remove duplicate graphics enable from performance-tuning.nix**

In `modules/performance-tuning.nix`, remove line 34-36:
```nix
  hardware.graphics = {
    enable = true;
```

Keep the rest of the `hardware.graphics` block (just remove the `enable = true;` line, keeping `extraPackages`):

```nix
  hardware.graphics.extraPackages = with pkgs; [
    libva
    libva-vdpau-driver
    libvdpau-va-gl
    mesa
    rocmPackages.clr.icd
  ];
```

- [ ] **Step 2: Verify and commit**

```bash
nix flake check
git add modules/performance-tuning.nix
git commit -m "fix: remove duplicate hardware.graphics.enable (already in default.nix)"
```

### Task 2.6: Fix neovim deprecation warnings

**Files:**
- Modify: `modules/neovim.nix`

- [ ] **Step 1: Add explicit withRuby and withPython3 settings**

In `modules/neovim.nix`, inside `programs.neovim`, add after `vimAlias = true;`:

```nix
          withRuby = false;
          withPython3 = false;
```

This silences the deprecation warnings and adopts the new default behavior (the old default of `true` was causing warnings because `home.stateVersion` is < 26.05).

- [ ] **Step 2: Verify warnings are gone**

```bash
nix flake check
```
Expected: No more neovim withRuby/withPython3 warnings.

- [ ] **Step 3: Commit**

```bash
git add modules/neovim.nix
git commit -m "fix: silence neovim deprecation warnings by adopting new defaults"
```

### Task 2.7: Fix music-menu /tmp safety issue

**Files:**
- Modify: `modules/music-menu.nix`

- [ ] **Step 1: Change /tmp to use XDG_RUNTIME_DIR**

In `modules/music-menu.nix`, change line 19 from:
```bash
) > /tmp/music_menu_full.list
```
To:
```bash
) > "''${XDG_RUNTIME_DIR:-/tmp}/music_menu_full.list"
```

And update all references from `/tmp/music_menu_full.list` to `"''${XDG_RUNTIME_DIR:-/tmp}/music_menu_full.list"` (lines 23, 32, 34, 37).

- [ ] **Step 2: Verify and commit**

```bash
nix flake check
git add modules/music-menu.nix
git commit -m "fix: use XDG_RUNTIME_DIR for music-menu temp files"
```

### Task 2.8: Fix fake email in git.nix

**Files:**
- Modify: `modules/git.nix`

- [ ] **Step 1: Update email to real address**

This requires the user's real email. For now, change `email@exemple.com` to a placeholder that clearly indicates it needs updating:

In `modules/git.nix`, change line 13:
```nix
          email = "email@exemple.com";
```
To the user's actual email. **ASK THE USER** for their preferred git email before committing.

- [ ] **Step 2: Verify and commit**

```bash
nix flake check
git add modules/git.nix
git commit -m "fix: update git email to actual address"
```

---

## Phase 3: Standardization & Refactoring (MEDIUM RISK)

### Task 3.1: Standardize indentation across all HM modules

**Files:**
- Modify: All modules with inconsistent indentation in `home-manager.users.${username}` blocks

The pattern to fix: 8-space indentation inside HM blocks should be 2-space (following Nix convention in AGENTS.md). Modules with this issue: `terminal.nix`, `vscode.nix`, `noctalia.nix`, `walker.nix`, `btop.nix`, `notifications.nix`, `brave.nix`, `obsidian.nix`, `tealdeer.nix`.

- [ ] **Step 1: Reindent terminal.nix**

Reindent the `home-manager.users.${username}` block to use 2-space indentation consistently. The inner HM config block should follow standard Nix 2-space indentation.

- [ ] **Step 2: Reindent the remaining modules one by one**

Apply the same 2-space indentation fix to each module. Each module gets its own commit so we can bisect if needed.

- [ ] **Step 3: Verify after all reindentation**

```bash
nix flake check
```

- [ ] **Step 4: Commit (one commit per module, or batch if preferred)**

```bash
git add modules/
git commit -m "style: standardize indentation across HM modules"
```

### Task 3.2: Centralize theme colors as Nix let bindings

**Files:**
- Create: `modules/theme-colors.nix` (shared color definitions)
- Modify: `modules/terminal.nix` (use theme-colors)
- Modify: `modules/walker.nix` (use theme-colors)
- Modify: `modules/zellij.nix` (use theme-colors)
- Modify: `modules/btop.nix` (use theme-colors)
- Modify: `modules/theme.nix` (use theme-colors)
- Modify: `modules/pdf.nix` (use theme-colors)

- [ ] **Step 1: Create theme-colors.nix with shared Tokyonight palette**

Create `modules/theme-colors.nix`:
```nix
{ ... }:
let
  colors = {
    bg = "1a1b26";
    fg = "c0caf5";
    blue = "7aa2f7";
    red = "f7768e";
    green = "9ece6a";
    yellow = "e0af68";
    magenta = "bb9af7";
    cyan = "7dcfff";
    dark = "15161e";
    comment = "565f89";
    border = "89b4fa";
    selection = "414868";
  };
in {
  imports = [ ];
  home-manager.users.david = { ... }: {
    # Export colors for other modules via lib
    _module.args.colors = colors;
  };
}
```

**NOTE:** This approach needs careful testing — NixOS module args propagation can be tricky. An alternative simpler approach is to just define the `colors` attrset and import it via `imports` or `let` in each module.

- [ ] **Step 2: Test alternative — shared let import**

A simpler approach: create `modules/_theme-let.nix` that contains just the `let` block, and import it. However, Nix doesn't support partial file imports easily. The cleanest NixOS approach is:

Create `modules/theme-colors.nix` as a module that sets `home-manager.users.${username}.lib.colors` or similar. Actually, the simplest Nix-idiomatic way is to define the colors in a `let` block at the top of `home.nix` or create a shared `lib/` directory.

**Recommended simplest approach:** Create `lib/colors.nix`:
```nix
rec {
  tokyonight = {
    bg = "1a1b26";
    fg = "c0caf5";
    blue = "7aa2f7";
    red = "f7768e";
    green = "9ece6a";
    yellow = "e0af68";
    magenta = "bb9af7";
    cyan = "7dcfff";
    dark = "15161e";
    comment = "565f89";
    border = "89b4fa";
    selection = "414868";
  };
}
```

Then import it in each module with `let colors = import ../lib/colors.nix; in`.

- [ ] **Step 3: Apply theme colors to each module**

Replace hardcoded color hex values with `colors.tokyonight.bg`, etc. Test each module individually.

- [ ] **Step 4: Verify and commit**

```bash
nix flake check
nos
git add -A
git commit -m "refactor: centralize theme colors into lib/colors.nix"
```

### Task 3.3: Extract inline shell scripts to scripts/ directory

**Files:**
- Modify: `modules/music-menu.nix` (move script to `scripts/music-menu.sh`)
- Modify: `modules/yt-search.nix` (move script to `scripts/yt-search.sh`)
- Modify: `modules/antigravity.nix` (ALREADY DELETED in Phase 1)
- Modify: `modules/tmux.nix` (ALREADY DELETED in Phase 1)

- [ ] **Step 1: Create scripts/music-menu.sh**

Extract the shell script content from `modules/music-menu.nix` into `scripts/music-menu.sh`. Then in the Nix module, reference it with:

```nix
home.packages = [
  (pkgs.writeShellScriptBin "music-menu" (builtins.readFile ../scripts/music-menu.sh))
];
```

- [ ] **Step 2: Create scripts/yt-search.sh**

Same approach for yt-search.

- [ ] **Step 3: Verify and commit**

```bash
nix flake check
nos
git add -A
git commit -m "refactor: extract shell scripts to scripts/ directory"
```

---

## Phase 4: Module Consolidation (HIGHER RISK)

### Task 4.1: Create modules/ai.nix (consolidate claude + gemini + opencode)

**Files:**
- Create: `modules/ai.nix`
- Remove: `modules/claude.nix`, `modules/gemini.nix`, `modules/opencode.nix`

- [ ] **Step 1: Create ai.nix**

Merge the three AI modules into one. The new `modules/ai.nix`:

```nix
{ config, lib, pkgs, username, inputs, ... }:

let
  pkgs-master = import inputs.nixpkgs-master {
    inherit (pkgs) system;
    config = pkgs.config;
  };
in
{
  home-manager.users.${username} = { config, lib, ... }:
    let
      mcpServers = {
        github = {
          command = "${pkgs.nodejs}/bin/npx";
          args = [ "-y" "@modelcontextprotocol/server-github" ];
          env = {
            GITHUB_TOKEN = "$(cat /home/${username}/.config/sops/github_token)";
          };
        };
      };
    in
    {
      home.packages = with pkgs; [
        opencode
        opencode-claude-auth
        gemini-cli
        go
        pkgs-master.claude-code
      ];

      xdg.configHome = lib.mkDefault "${config.home.homeDirectory}/.config";

      # Claude Code settings
      home.file.".claude/settings.json" = {
        force = true;
        text = lib.generators.toJSON { } {
          model = "sonnet";
          env = {
            MAX_THINKING_TOKENS = "8000";
          };
          mcpServers = mcpServers // {
            nixos = {
              command = "uvx";
              args = [ "mcp-nixos" ];
              env = { };
            };
            fetch = {
              command = "uvx";
              args = [ "mcp-server-fetch" "--ignore-robots-txt" ];
              env = { };
            };
          };
        };
      };

      # Gemini settings symlink (mutable for session state)
      home.file."nixos-config/.gemini/settings.json".source =
        config.lib.file.mkOutOfStoreSymlink "/home/${username}/nixos-config/.agent/gemini-settings.json";
    };
}
```

- [ ] **Step 2: Remove old modules**

```bash
rm modules/claude.nix modules/gemini.nix modules/opencode.nix
```

- [ ] **Step 3: Verify and commit**

```bash
nix flake check
nos
git add -A
git commit -m "refactor: consolidate AI modules into ai.nix"
```

### Task 4.2: Create modules/gaming.nix (consolidate steam + lact + gpu-screen-recorder)

**Files:**
- Create: `modules/gaming.nix`
- Remove: `modules/steam.nix`, `modules/lact.nix`, `modules/gpu-screen-recorder.nix`

- [ ] **Step 1: Create gaming.nix**

Merge steam, lact, and gpu-screen-recorder into one module. All are system-level gaming/AMD GPU modules.

- [ ] **Step 2: Remove old modules**

```bash
rm modules/steam.nix modules/lact.nix modules/gpu-screen-recorder.nix
```

- [ ] **Step 3: Verify and commit**

```bash
nix flake check
nos
git add -A
git commit -m "refactor: consolidate gaming modules into gaming.nix"
```

### Task 4.3: Create modules/media.nix (consolidate music-menu + yt-search + yt-dlp + mpv)

**Files:**
- Create: `modules/media.nix`
- Remove: `modules/music-menu.nix`, `modules/yt-search.nix`, `modules/yt-dlp.nix`

Currently `mpv` config is in `modules/utils.nix`. Move it here too for logical grouping.

- [ ] **Step 1: Create media.nix with all music/video config**

Include: yt-dlp settings, fish functions (`yt`, `mpno`, `mkpl`), music-menu script, yt-search script, mpv config.

- [ ] **Step 2: Remove mpv config from utils.nix and old modules**

- [ ] **Step 3: Verify and commit**

```bash
nix flake check
nos
git add -A
git commit -m "refactor: consolidate media modules into media.nix"
```

### Task 4.4: Remove `programs.fuzzel.enable = false` from walker.nix

**Files:**
- Modify: `modules/walker.nix` (remove fuzzel disable — it's not installed anyway)

- [ ] **Step 1: Remove the fuzzel disable line**

Remove line 219 from `modules/walker.nix`:
```nix
        programs.fuzzel.enable = false;
```

- [ ] **Step 2: Verify and commit**

```bash
nix flake check
git add modules/walker.nix
git commit -m "fix: remove unnecessary fuzzel disable in walker.nix"
```

---

## Phase 5: Documentation & Final Polish (LOW RISK)

### Task 5.1: Update project_map.md

**Files:**
- Modify: `memory/reference/project_map.md`

After all structural changes, regenerate the project map to reflect:
- Removed modules (antigravity, tmux, claude, gemini, opencode, steam, lact, gpu-screen-recorder, music-menu, yt-search, yt-dlp)
- New modules (ai, gaming, media)
- New file (lib/colors.nix)
- Removed pkgs (google-antigravity)

- [ ] **Step 1: Update project_map.md**

- [ ] **Step 2: Commit**

```bash
git add memory/reference/project_map.md
git commit -m "docs: update project map after rearchitecture"
```

### Task 5.2: Update README.md

**Files:**
- Modify: `README.md`

The README currently references "Sly-Harvey" style and outdated structure. Update to reflect current state.

- [ ] **Step 1: Update README**

- [ ] **Step 2: Commit**

```bash
git add README.md
git commit -m "docs: update README to reflect current project structure"
```

### Task 5.3: Update AGENTS.md

**Files:**
- Modify: `AGENTS.md`

Update AGENTS.md to reflect the new module naming conventions and consolidated modules.

- [ ] **Step 1: Update AGENTS.md**

- [ ] **Step 2: Commit**

```bash
git add AGENTS.md
git commit -m "docs: update AGENTS.md for rearchitected module structure"
```

---

## Verification Checklist

After ALL phases are complete:

- [ ] `nix flake check` passes without unexpected errors
- [ ] `nos` builds and applies successfully
- [ ] No neovim deprecation warnings
- [ ] Brave browser opens correctly
- [ ] Niri compositor starts
- [ ] Walker launcher works
- [ ] Zellij starts with dev layout
- [ ] AI tools (opencode, claude-code, gemini) are available
- [ ] Steam/games launch correctly
- [ ] Music scripts work (music-menu, yt-search)
- [ ] Git config has correct email
- [ ] No duplicate packages in build