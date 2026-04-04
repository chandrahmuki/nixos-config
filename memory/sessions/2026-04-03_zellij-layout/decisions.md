---
Generated: 2026-04-03 11:06 UTC
---

# Decisions Made

### zjstatus en haut
**Why:** Préférence utilisateur
**How:** `children` placé après le pane zjstatus dans `default_tab_template`

### Proportions layout extraites live
**Why:** Plus précis que d'estimer à la main
**How:** `zellij action dump-layout --session <nom>` depuis le terminal Claude Code

### Sérialisation Zellij = pas de persistence au reboot
**Decision:** Ne pas essayer de persister le cache Zellij via Nix (trop complexe, gain limité)
**Alternative rejetée:** Script systemd save/restore du cache
**Conclusion:** Tout ce qui doit être permanent → dans le KDL Nix

### Tab Monitoring avec btop
**Why:** Remplace l'ancien tab "Server/Logs" qui était vide et sans utilité
