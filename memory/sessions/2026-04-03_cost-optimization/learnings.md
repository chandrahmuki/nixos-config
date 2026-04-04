# Learnings & Insights

**Generated:** 2026-04-03 10:02 UTC

## Key Discoveries

- settings.json is managed by Home Manager — must edit claude.nix, not the file directly
- Skills in ~/.claude/plugins/cache/ are the ones actually used, not ~/.claude/skills/
- reload-plugins shows 0 skills — user-invocable skills may require full restart

