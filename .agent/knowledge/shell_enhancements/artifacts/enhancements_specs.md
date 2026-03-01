# 🐚 Shell Enhancements: Atuin, Zoxide & Fish Vi Mode

## 🚀 Zoxide (Smart Navigation)
Zoxide remplace le plugin Fish `z` par un module déclaratif plus performant.
- **Module** : `programs.zoxide`
- **Configuration** :
  - `enableFishIntegration = true`
  - `options = [ "--cmd cd" ]` (remplace la commande par défaut `cd` pour apprendre automatiquement les chemins).
- **Usage** : `cd <dossier>` ou `zi` pour la recherche interactive.

## 📜 Atuin (History Manager)
Atuin remplace l'historique shell classique par une base SQLite synchronisable.
- **Module** : `programs.atuin`
- **Configuration** :
  - `enableFishIntegration = true`
  - `search_mode = "fuzzy"`
  - `auto_sync = true`
- **Usage** : `Ctrl+R` déclenche l'interface Atuin.

## ⌨️ Fish Vi Mode
Le mode Vi est activé dans Fish pour une navigation efficace au clavier.
- **Activation** : `fish_vi_key_bindings` dans `interactiveShellInit`.
- **Raccourcis Personnalisés** :
  - **`jk`** : Sortir du mode insertion vers le mode Normal (équivalent `Esc`).
- **Styles de Curseur** :
  - `Insert` : Barre (`line`)
  - `Normal/Visual` : Bloc (`block`)
  - `Replace` : Souligné (`underscore`)

## 🛠️ Custom Functions (Fish)
Des fonctions utilitaires sont ajoutées dans `modules/utils.nix` pour simplifier les tâches courantes :
- **`mpno`** : Lance `mpv --no-video $argv`. Idéal pour écouter de la musique sans ouvrir de fenêtre vidéo.
- **`search`** : Recherche interactive globale via `fd` et `fzf`.

## 📦 Outils Complémentaires
- **`qpdf`** : Installé pour la manipulation de PDF (ex: `qpdf --decrypt` pour supprimer les mots de passe).

## ⌨️ Neovim Productivity (Which-Key)
Le menu `which-key` est structuré pour une navigation intuitive :
- **Groupes** :
  - **`<leader>f`** : [F]iles / Exploration
  - **`<leader>g`** : [G]it operations
  - **`<leader>s`** : [S]earch / Pickers
  - **`<leader>w`** : [W]indow navigation (remplace la navigation leader directe)
  - **`<leader>b`** : [B]uffers
- **Icônes** : Utilisation de Nerd Fonts pour une identification rapide.
- **Raccourcis Clés** :
  - `<leader>wh/wj/wk/wl` : Déplacement entre les fenêtres.
  - `<leader>fe` : Explorateur de fichiers (Snacks).
  - `<leader>qq` : Quitter proprement.

## 🛠️ Intégration
Ces modules sont importés dans `home.nix` et configurés spécifiquement pour Fish dans leurs modules respectifs (principalement `modules/terminal.nix` et `modules/utils.nix`).
