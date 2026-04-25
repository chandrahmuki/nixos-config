# Nix Flakes — Lessons Learned

- 2026-04-23: Pin commit quand build upstream cassé (opencode 62bd0230)
- 2026-04-23: Unpin quand fix released (v1.14.21/22)
- 2026-04-08: `inputs.nixpkgs.follows = "nixpkgs"` pour éviter doublons
- 2026-04-03: Registry pin: `nix.registry.nixpkgs.flake = inputs.nixpkgs`
