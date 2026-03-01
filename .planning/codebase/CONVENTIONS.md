# Coding Conventions

**Analysis Date:** 2026-03-01

## Naming Patterns

**Files:**
- kebab-case.nix - standard for Nix modules.
- PascalCase.tsx - (if React used in the future).
- README.md, GEMINI.md - uppercase for important docs.

**Nix Modules:**
- `{ config, pkgs, ... }: { ... }` - standard module signature.
- `imports = [ ... ]` - top-level array of imported files.

**Variables:**
- camelCase - standard for Nix variables.
- `_key_file` - snake_case for internal shell variables (Fish).

## Code Style

**Nix:**
- Declarative attribute sets.
- Comments explaining the *why* for complex options.
- 2 spaces indentation.

**Shell (Fish):**
- Function-based organization for visual tools.
- Mode-aware key bindings (Vim).

## Commenting Guidelines

**Why, not What:**
- Comments should explain non-obvious Nix options.
- Comments are required for all modifications to facilitate system understanding.

---
*Conventions analysis: 2026-03-01*
