Generated: 2026-04-03

## Session: Memory System Refactor

### Context
User noticed session costs were running $14-15/day and asked how to reduce them. Investigation revealed the memory system had monolithic files loaded entirely into context even when irrelevant.

### What Was Done
Complete refactor of the `~/.claude/projects/.../memory/reference/` system:

1. **Diagnosed cost drivers** — `applications.md` (25KB), `nixos_core.md` (15KB), `development.md` (11KB) were loaded as single blobs
2. **Split into 17 targeted files** — each ≤5KB, loaded only when relevant to the task
3. **Removed obsolete content** — 9 sections dropped (derivable from code, Gemini-specific workflows, trivial docs)
4. **Updated MEMORY.md** — new index organized by domain with descriptive one-liners

### Net result
Memory reference total: **82KB → 23KB (-72%)**
Files: **8 monolithic → 17 focused**

### Commits this session
None — this was pure memory/documentation work (no NixOS config changes).

Last NixOS commit: `f896865` — fix: nix optimisations (sysctl duplicate, nix-community cache, async, registry pin)
