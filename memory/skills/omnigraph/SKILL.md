---
name: omnigraph
description: Query the omnigraph dependency graph for context before editing Nix modules. Supports check, query, orphans, and session-resume.
user-invocable: true
argument-hint: <command> [target]
---

# Omnigraph Skill

Query the project dependency graph via the `omnigraph` CLI (Bun + SQLite).

## When
- Before editing any `.nix` module
- When user asks "what depends on X" or "what does X affect"
- At session resume (auto-query last session's modules)
- Invoked: `/omnigraph check modules/niri.nix`

## Commands

### check <file-path>
Pre-edit impact analysis. Shows imports, inputs, reverse deps, sessions, lessons, risk level.
```
omnigraph check modules/niri.nix
```

### query <search-term>
Search nodes by label or ID. Returns matching node list.
```
omnigraph query niri
```

### orphans
Detect unused flake inputs, dead file references, isolated nodes.
```
omnigraph orphans
```

### session-resume
Auto-query context for the last session. Reads the latest summary, then runs `check` on each modified module.
```
1. Find latest: ls -t memory/sessions/ | head -1
2. Read summary.md
3. For each module in "Files Modified": omnigraph check <module>
4. Present compact context report
```

## Process

1. **Verify DB exists** — If `.omnigraph/graph.db` missing, run `omnigraph build` first
2. **Run command** — Use `bun run ~/.local/share/omnigraph/omnigraph.ts <command> [args]` from project root
3. **Present results** — Max 15 lines, no prose, structured format

## Output Format (check)
```
## <module>
↓ uses_input: niri, sops-nix
↑ used_by: 10 sessions
📝 sessions: noctalia-fix, neovim-modernization, ...
⚠️ risk: HIGH (10 reverse deps)
```

## Invoke
```
/omnigraph check modules/niri.nix
/omnigraph query sops
/omnigraph orphans
/omnigraph session-resume
```