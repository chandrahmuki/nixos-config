---
name: graph-check
description: Query the omnigraph knowledge graph before editing a Nix module. Shows dependencies, related sessions, lessons, and potential impact.
user-invocable: true
argument-hint: [<module-path>]
---

# Graph Check Skill

Query the omnigraph DB before editing a Nix module to surface context that prevents errors.

## When
- Before editing any `.nix` file in modules/, hosts/, or root
- When user asks "what depends on X" or "what does X affect"
- Invoked: `/graph-check modules/niri.nix`

## Process

1. **Resolve target** — If no argument, use the file the user is about to edit
2. **Query omnigraph** — Run the bash command below against `.omnigraph/graph.db`
3. **Present compact report** — Max 10 lines, no prose

## Queries

### Direct dependencies (what this file imports/uses)
```sql
SELECT e.type, e.to_id FROM edges e
WHERE e.from_id = '<TARGET>'
ORDER BY e.type;
```

### Reverse dependencies (what uses this file)
```sql
SELECT e.type, e.from_id FROM edges e
WHERE e.to_id = '<TARGET>'
ORDER BY e.type;
```

### Sessions that modified this file
```sql
SELECT e.from_id FROM edges e
WHERE e.to_id = '<TARGET>' AND e.type = 'session_modified'
ORDER BY e.from_id DESC LIMIT 5;
```

### Lessons that apply
```sql
SELECT e.from_id FROM edges e
WHERE e.to_id = '<TARGET>' AND e.type = 'lesson_applies_to';
```

### Options provided/consumed by this file
```sql
SELECT e.type, e.to_id FROM edges e
WHERE e.from_id = '<TARGET>' AND e.type IN ('provides_option', 'consumes_option');
```

## Output Format
```
## <module>
↓ imports: colors.nix, ...
↓ uses_input: niri, sops-nix, ...
↑ used_by: (nothing / niri.nix, ...)
📝 sessions: 2026-04-08_rearchitecture, 2026-04-21_noctalia-fix
📖 lessons: nix-modules
⚙️ provides: programs.fish.shellAliases
⚙️ consumes: hardware.graphics
⚠️ risk: (high if >3 reverse deps / medium if 1-2 / low if none)
```

## Invoke
```
/graph-check modules/niri.nix
```
