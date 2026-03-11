# Noctalia Suspend-Resume Orange Screen (OSoD)

## Problème
Lors d'une longue mise en veille (plusieurs heures), le `noctalia-shell` peut crasher au réveil, laissant le compositeur (niri/hyprland) afficher son arrière-plan d'urgence (typiquement orange ou rouge).

## Causes Possibles
- **Issue #2139** : Échec du mapping des surfaces lors du resume.
- **Race Condition** : Instanciation de composants (notifications, widgets) avant que l'état du GPU ne soit restauré.
- **Separate Settings Mode** : Connu pour accentuer les crashs lors du changement de résolution au wake.

## Méthodes de Récupération
1. **Blind Password** : Taper le mot de passe à l'aveugle + Entrée.
2. **TTY Restart** : 
   - `Ctrl+Alt+F3`
   - Se connecter.
   - `systemctl --user restart noctalia.service`.

## Solution (Fix)
- **Update Noctalia** : Le fix est en cours d'intégration dans `main` (Issue #2139).
- **Update flake.lock** : S'assurer que `noctalia-qs` est au moins en version `0.0.7` (via PR #2149).
