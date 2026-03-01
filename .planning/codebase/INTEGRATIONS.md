# External Integrations

**Analysis Date:** 2026-03-01

## APIs & External Services

**GitHub:**
- Repo: `github:nixos-config`.
- SDK/Client: `npx @modelcontextprotocol/server-github`.
- Auth: Personal Access Token in `.config/antigravity/github_token`.

**Gemini (Google DeepMind):**
- Integration: `gemini-cli`.
- Auth: API Key in `.config/antigravity/gemini_api_key`.

**OpenClaw / Social Development:**
- Skill: `skill-gsd`.
- Workflow: `get-shit-done`.

## Data Storage

**Filesystem:**
- Local storage for dotfiles, modules, and hosts.
- Symlinks: Managed by Home Manager (`/nix/store/` -> `~/`).

**Secrets:**
- Sops-nix: Decrypted YAML in `/run/secrets/` or through user-level environment variables.

## CI/CD & Deployment

**System Update:**
- `nh os switch --flake .#muggy-nixos`.
- Manual flake update for nixpkgs and inputs.

**Backup & Recovery:**
- Git version control for all configuration state.

---
*Integration audit: 2026-03-01*
