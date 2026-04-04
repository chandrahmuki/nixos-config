# Fixes & Resolutions

**Generated:** 2026-04-03 10:02 UTC

## Bugs Fixed

- Snapshot skill was generating empty placeholder files — fixed with real transcript parsing
- create_snapshot.py had no implementation — rewrote with parse_git_log() and analyze_session_text()
- Snapshot priority order fixed: transcript > manual JSON > git log fallback

