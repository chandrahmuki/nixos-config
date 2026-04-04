# Decisions Made

**Generated:** 2026-04-03 10:02 UTC

## Architectural & Technical Decisions

- Implement SessionStart hook to capture transcript_path for /snapshot skill
- Use Option 2: User-Invoked Skill + SessionStart Hook for session data access
- Change default model from haiku to sonnet in claude.nix
- Limit MAX_THINKING_TOKENS to 8000 to reduce costs
- Add user-invocable: true to SKILL.md for /snapshot slash command

