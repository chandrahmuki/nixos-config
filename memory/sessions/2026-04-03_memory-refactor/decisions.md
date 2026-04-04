Generated: 2026-04-03

## Decisions Made

### Architecture: One file per topic, not one file per domain
**Why:** A monolithic `applications.md` (25KB) gets loaded entirely even when only touching Yazi. Individual files are loaded only when the task description matches.
**Impact:** Context cost proportional to task scope, not total knowledge base size.

### What to keep vs drop
**Keep** (non-obvious, not in code):
- Procedural knowledge (antigravity update steps, ZMK pairing procedure)
- Bug fixes with non-obvious causes (Yazi m3u mime type, Niri spawn syntax)
- Architectural decisions with non-obvious rationale (MPV IPC socket, Zellij wasm symlinks, Mako vs SwayNC)
- Active rules (git staging, HM force=true ban, vault-clean standards)

**Drop** (derivable from code or obsolete):
- Config that mirrors what's already in .nix modules (Brave flags, Zathura colors, etc.)
- Generic NixOS tutorials (bootstrap automation, portability patterns)
- Gemini-specific workflows (triple-relay, context-switch commands)
- Trivial package lists (disk monitoring tools)

### workflows.md deleted entirely
**Why:** Entire file was about Gemini CLI workflows (`/audit`, `/archive`, `/git-sync`). Completely obsolete for Claude Code.
