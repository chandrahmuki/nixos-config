---
name: snapshot
description: Create a compact structured snapshot of the current session into memory/sessions/
user-invocable: true
argument-hint: [--topic=<name>]
---

# Snapshot Skill

Persist key session info to `memory/sessions/YYYY-MM-DD_<topic>/summary.md`.

## When
- Important decisions, fixes, new modules
- NOT for minor changes

## Process

1. **Git check** — `git status` first
   - If dirty: ask "commit avant snapshot ?" (wait confirmation)
   - If clean: proceed, then run `git log --oneline -20`

2. **Skills check** — `ls -lt ~/.claude/skills/` for modified today

3. **Create ONE file** — `summary.md` only
   - Max 5 bullets per section
   - No code, no sentences
   - Include commit hashes + messages

4. **Size check** — If >2KB, warn user before writing

5. **Update** `memory/index_sessions.md`

## Output Format
```markdown
---
Generated: 2026-04-03 20:15 UTC
Topic: zellij opencode
---

## What Was Accomplished
- Changed zellij dev layout to launch opencode
- Enabled fish integration in zellij

## Commits This Session
- `b5c7555` feat: enable fish integration in zellij

## Skills Modified
- snapshot: added skills check step
```

## Invoke
```
/snapshot
```
Optional: `/snapshot --topic custom-topic`
