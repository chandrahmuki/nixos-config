# Architecture : Zellij-Neovim Perfect Setup

Cette architecture vise à transformer le terminal en une plateforme de développement cohérente où les outils ne sont plus des silos isolés.

## Composants Clés

### 1. Navigation Transversale (Smart-Splits)
- **Plugin Nvim** : `mrjones2014/smart-splits.nvim`
- **Config Zellij** : Keybinds `Alt+h/j/k/l` mappés sur `MoveFocusOrTab` ou `MoveFocus`.
- **Résultat** : Une seule commande pour naviguer entre buffers Nvim et terminaux Zellij.

### 2. Autolock (Context Awareness)
- **Plugin Zellij** : `zellij-autolock`
- **Fonctionnement** : Détecte l'exécution de `nvim` et verrouille instantanément l'interface Zellij.
- **Bénéfice** : Liberté totale des raccourcis Neovim (indispensable pour les Power Users).

### 3. Persistance des Sessions (Stable Symlinks)
- **Problème** : Les liens vers les plugins `.wasm` du store Nix expirent après un `garbage-collect`, cassant les sessions Zellij en cours.
- **Solution** : Utilisation de `home.file` pour créer des liens symboliques stables dans `~/.config/zellij/plugins/`.
- **Implémentation** : Zellij et ses layouts pointent vers ces chemins fixes, assurant une disponibilité ininterrompue des plugins (ex: `zjstatus`).

### 4. Layout "Dev" (Spatial Organization)
Le layout `dev.kdl` structure l'espace de manière logique :
- **Editor (Gauche, 75%)** : Zone de focus principale (Neovim).
- **AI Workspace (Droite haut, 12%)** : Pane dédié à `antigravity` (ou `gemini-cli`).
- **Shell (Droite bas, 13%)** : Exécution rapide de commandes.

### 4. Persistance Manuelle (Style Tmux)
- **Sérialisation** : Activation de `session_serialization` et `pane_viewport_serialization` dans les `settings`.
- **Flexibilité** : Suppression des commandes forcées (`nvim`, `gemini`) dans le layout Nix pour permettre à Zellij de mémoriser les outils lancés manuellement.
- **Résultat** : Les fenêtres reviennent avec leurs outils après un reboot du PC, tout en conservant la structure définie par Nix.

## 🛠️ Commandes Zellij CLI Utiles
- **Voir les sessions** : `zellij list-sessions` (ou `zellij ls`)
- **Attacher à une session** : `zellij attach -c <nom-de-session>` (le flag `-c` crée la session si elle n'existe pas)
- **Supprimer une session** : `zellij delete-session <nom-de-session>`
- **Tuer toutes les sessions** : `zellij delete-all-sessions`

## Maintenance NixOS
La configuration est entièrement déclarative dans `modules/zellij.nix`. Le déploiement via Home Manager garantit la cohérence entre les binaires, les plugins et les fichiers de configuration.
