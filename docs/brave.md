# 🌐 Configuration de Brave sur NixOS

Cette fiche explique comment Brave est configuré pour concilier sécurité (extensions forcées) et confort visuel (Wayland, Dark Mode).

## 🛡️ Politiques Système (Extensions & PWAs)
Nous utilisons les politiques **Chromium** globales pour forcer des éléments essentiels.
- **Fichier** : `modules/brave-system.nix`
- **Extensions forcées** : Bitwarden, uBlock Origin.
- **PWAs forcées** : Microsoft Teams.

## 🎨 Interface et Performance (UI & Wayland)
La configuration utilisateur via Home-Manager optimise le rendu graphique.
- **Fichier** : `modules/brave.nix`
- **Wayland Natif** : Activé via `--ozone-platform=wayland` pour une meilleure fluidité sur les tiling managers (Niri).
- **Dark Mode** : Forcé via `--force-dark-mode` (UI) et `--enable-features=WebContentsForceDark` (contenu).

## 🔧 Maintenance rapide
- **Ajouter une extension** : Ajouter l'ID dans `modules/brave-system.nix`.
- **Désactiver le Dark Mode** : Modifier `commandLineArgs` dans `modules/brave.nix`.
