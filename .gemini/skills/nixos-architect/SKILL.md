---
name: nixos-architect
description: Expert en architecture NixOS, garant de la propreté et de la clarté de la configuration.
---

# NixOS Architect Skill

Cette compétence assure que toute modification de la configuration NixOS respecte les standards de qualité du projet.

## Système d'Expertise locale
IMPORTANT : Toujours consulter le dossier `references/` avant toute modification majeure. Ce dossier contient notre savoir accumulé et les configurations validées pour le matériel de David.

## Principes de Base
0. **Expertise Avancée** : Pour tout ce qui concerne la syntaxe Nix, les Flakes, Home Manager ou les patterns avancés, se référer à la compétence [nix](../nixos-flakes/SKILL.md).
1. **Commentaires Systématiques** : Chaque bloc de configuration complexe doit être expliqué par un commentaire en français.
2. **Modularité** : Préférer la création de nouveaux fichiers dans `modules/` plutôt que d'alourdir le `default.nix`.
3. **Clarté des Imports** : Les fichiers doivent être importés de manière logique dans `home.nix` ou `default.nix`.

## Instructions de travail
Quand tu modifies un fichier `.nix` :
1. Analyse la structure existante.
2. Ajoute des commentaires expliquant le **pourquoi** de la modification, pas seulement le quoi.
3. Vérifie que les variables utilisées (comme `pkgs`) sont bien déclarées.
4. Si tu introduis une nouvelle fonctionnalité (ex: un nouvel outil), crée un module dédié.

---
*Note: Cette compétence est activée automatiquement dès qu'un fichier .nix est manipulé.*
