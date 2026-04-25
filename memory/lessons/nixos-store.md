# Nix Store — Lessons Learned

- 2026-04-23: `nh clean all` libère ~40Go (56G → 16G)
- `nh.clean` auto = générations uniquement (7j/5)
- `nix.optimise.automatic = true` = déduplication async
- Rollback limité après `nh clean all` (5 dernières générations)
