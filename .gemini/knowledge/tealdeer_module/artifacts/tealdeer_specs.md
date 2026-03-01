# 🦌 Module Tealdeer

## Description
`tealdeer` est une implémentation rapide et performante en **Rust** du projet `tldr`. Il permet d'afficher des pages d'aide simplifiées et communautaires pour les commandes Linux.

## Utilité
Contrairement aux `man pages` qui sont exhaustives mais souvent complexes, `tealdeer` fournit des exemples concrets et actionnables pour les commandes les plus courantes.

## Configuration actuelle
Le module est configuré dans `modules/tealdeer.nix` avec les options suivantes :
- **Mode Compact** : Affichage réduit pour plus de clarté.
- **Auto-Update** : Les pages d'aide sont mises à jour automatiquement.
- **Pager** : Utilisation du pager système pour la lecture.

## Utilisation
Une fois le système déployé, exécutez simplement :
```bash
tldr <commande>
```
*Exemple : `tldr tar`*
