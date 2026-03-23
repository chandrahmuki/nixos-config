# Spec Design : Navigation Unifiée Zellij + Yazi + Neovim

**Date :** 2026-03-23
**Status :** Draft
**Author :** Gemini CLI (Expert NixOS & Neovim)

## 1. Contexte & Problématique
L'utilisateur actuel dispose d'un workflow où il utilise Neovim pour l'édition et l'exploration de fichiers (via `Snacks.explorer`). Cependant, la navigation entre l'explorateur de fichiers interne et le buffer de code est jugée trop lente (`Space + w` suivi de `hjkl`). Zellij est déjà configuré pour une navigation inter-panes fluide via `Alt + hjkl`.

**Objectif :** Rendre l'exploration de fichiers aussi rapide que la navigation entre les panes Zellij en utilisant **Yazi** comme explorateur de fichiers persistant à gauche de Neovim.

## 2. Solution Proposée
Transformer l'environnement de développement "MuggyVim" en un véritable IDE composite utilisant la puissance de Zellij pour l'agencement et la navigation.

### 2.1 Architecture du Layout Zellij (`dev`)
Le layout `dev` sera restructuré pour offrir une vue à 3 colonnes logiques :
1.  **Colonne Gauche (15%) :** Pane Yazi (Explorateur de fichiers).
2.  **Colonne Centrale (Focus, 60%) :** Pane Neovim.
3.  **Colonne Droite (25%) :** Gemini CLI + Terminal auxiliaire.

```nix
tab name="Editor" focus=true {
    pane split_direction="vertical" {
        pane size="15%" name="Files" command="yazi"
        pane name="Editor" focus=true command="nvim" { args "."; }
        pane size="25%" {
            pane name="Gemini CLI" command="gemini"
            pane name="Terminal"
        }
    }
}
```

### 2.2 Navigation Unifiée
L'utilisateur utilisera exclusivement **`Alt + h/j/k/l`** pour naviguer entre :
*   Yazi (à gauche)
*   Neovim (au centre)
*   Gemini/Terminal (à droite)

Cela évite les raccourcis doubles (ex: `leader w l`) et unifie l'expérience utilisateur.

### 2.3 Modifications Neovim
*   Désactiver ou masquer les raccourcis `Snacks.explorer` pour éviter la confusion.
*   Garder `Snacks.picker.smart` sur `<leader><space>` pour la recherche rapide de fichiers par nom.
*   Supprimer l'explorateur interne du flux de travail principal.

## 3. Contraintes & Risques
*   **Conflit de Focus :** Zellij doit être configuré pour que `Alt + l` (droite) sorte bien de Yazi pour entrer dans Neovim. C'est déjà le cas via `MoveFocusOrTab`.
*   **Synchronisation :** Yazi ne se "synchronisera" pas automatiquement sur le fichier ouvert dans Neovim. Si c'est un besoin futur, il faudra envisager un plugin plus complexe.

## 4. Stratégie de Test
1.  Lancer `zelldev` (alias de `zellij --layout dev`).
2.  Vérifier que Yazi se lance bien dans le pane de gauche.
3.  Naviguer de Yazi vers Neovim via `Alt + l`.
4.  Naviguer de Neovim vers Yazi via `Alt + h`.
5.  Vérifier que l'ouverture d'un fichier dans Yazi ne "vole" pas le focus de manière inattendue ou n'ouvre pas une instance de Neovim imbriquée (Yazi doit probablement être utilisé pour le parcours, et l'ouverture se fait soit via Yazi si configuré, soit simplement en switchant de pane). *Note: L'utilisateur peut aussi juste naviguer, copier le chemin, ou plus simplement utiliser le picker Neovim pour l'ouverture précise.*

## 5. Prochaines Étapes
1.  Mise à jour de `modules/zellij.nix`.
2.  Mise à jour de `nvim/lua/plugins/snacks.lua`.
3.  Mise à jour de `nvim/lua/plugins/whichkey.lua` (pour refléter les changements d'icônes/menus).
