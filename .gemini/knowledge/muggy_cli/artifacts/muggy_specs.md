# Muggy CLI - Spécifications Techniques

## Vue d'ensemble
CLI Go utilisant **Bubble Tea** pour rechercher, découvrir et installer des MCPs et Skills IA de manière déclarative sur NixOS.

## Architecture (Fichiers clés)

| Fichier | Rôle |
|---|---|
| `main.go` | État machine TUI (Bubble Tea), sous-commandes `search`/`install` |
| `scraper.go` | Recherche GitHub + extraction commandes d'installation |
| `installer.go` | Injection dans `.nix` ou `.json`, scanner dynamique de cibles |

## Recherche de Skills (2 stratégies)

### 1. Code Search API (précise, auth requise)
```
filename:SKILL.md path:.agent/skills <query>
filename:SKILL.md path:.gemini/skills <query>
```
- Nécessite `GITHUB_TOKEN` ou `GITHUB_PERSONAL_ACCESS_TOKEN`
- Retourne des skills individuels avec nom extrait du path
- Affichage : `skill-name (owner/repo)`

### 2. Fallback Topic-Based (sans auth)
```
<query> topic:agent-skill
<query> topic:claude-skill
<query> topic:gemini-skill
```
- Utilise le Repository Search API (pas d'auth nécessaire)
- Pattern factorisé via helper `searchRepos()`

## Recherche MCP
```
<query> topic:mcp-server
```
- Repository Search API, trié par étoiles, via `searchRepos()`

## Navigation TUI (État Machine)

```
SearchInput → Searching → SearchResults → TargetSelection → Installing → Done
     ↑              ↑             ↑               ↑                        |
     └── Esc ───────┘── Esc ──────┘─── Esc ───────┘──── Enter/Esc ────────┘
```

- **Esc** = retour à l'état précédent (jamais quitter)
- **Ctrl+C** = seul moyen de quitter globalement
- **Done → Enter** = reset complet, nouvelle recherche

## Scanner Dynamique de Cibles
- `filepath.WalkDir` depuis `$HOME` pour trouver les configs existantes
- Patterns reconnus : `.nix` (Gemini/NixOS) et `.json` (Antigravity)
- Option "Enter custom path..." pour chemins personnalisés

## Packaging Nix
- Défini dans `pkgs/muggy/default.nix` via `buildGoModule`
- Dépendance : `goquery` (scraping HTML)
