---
Generated: 2026-04-03 12:30 UTC
---

# Configuration Changes

## modules/zellij.nix

- Layout `dev.kdl` : remplacé `zellij:compact-bar` par zjstatus avec config complète
  - format_left : mode + session + tabs
  - format_right : git branch + datetime (Europe/Paris)
  - Couleurs Tokyo Night Moon
- Ajout fonction fish `zj` : `zellij attach main 2>/dev/null; or zellij --session main`

## zjstatus config dans le layout

```kdl
pane size=1 borderless=true {
    plugin location="file:/home/david/.config/zellij/plugins/zjstatus.wasm" {
        format_left  "{mode}#[fg=#89b4fa,bold] {session} {tabs}"
        format_right "{command_git_branch}#[fg=#424242,bold] | {datetime}"
        // ... couleurs modes, tabs, git, datetime
    }
}
```

## Workflow Zellij établi

- `zelldev` = nouvelle session avec layout zjstatus
- `zj` = attach à session "main" existante
- Sérialisation native Zellij = persist les panes ajoutés manuellement
- Layout Nix = seulement pour le state initial d'une nouvelle session
