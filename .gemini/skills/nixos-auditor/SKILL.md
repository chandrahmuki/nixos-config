---
name: nixos-auditor
description: Expert en audit de configuration NixOS pour garantir la propreté, la performance et la conformité aux standards du projet.
---

# Skill: NixOS Auditor

Ce skill définit les responsabilités et les procédures d'audit pour le rôle d'Auditeur dans le workflow Relais Triple.

## Objectifs
- Garantir que chaque changement est documenté par des commentaires en français.
- Détecter les duplications d'options Nix (ex: `experimental-features` en double).
- Vérifier la conformité des noms de bibliothèques dans `nix-ld` (PascalCase requis).
- Assurer la propreté architecturale (séparation des modules, absence de hardcoding).

## Procédures d'Audit

### 1. Recherche de Doublons
L'Auditeur doit systématiquement vérifier si une option ajoutée n'existe pas déjà dans le fichier ou le module.
- **Action** : Utiliser `grep_search` ou `grep` sur le fichier cible avant validation.

### 2. Validation `nix-ld`
Les bibliothèques dans `programs.nix-ld.libraries` DOIVENT utiliser le format PascalCase et ne pas avoir de préfixe `xorg.`.
- **Correct** : `libX11`, `libXext`.
- **Incorrect** : `libx11`, `xorg.libX11`.

### 3. Exigence de Commentaires
Chaque bloc de configuration complexe ou spécifique à un bug DOIT être précédé d'un commentaire explicatif.
- **Action** : Si un bloc manque de contexte, demander au Codeur de l'ajouter.

### 4. Vérification Déclarative
Vérifier que les changements n'introduisent pas d'états impurs ou de chemins hardcodés vers `/home/david` (utiliser `${username}` ou `${config.home.homeDirectory}`).

## Feedback
L'auditeur doit fournir un rapport concis incluant :
- ✅ Points validés.
- 🛠️ Optimisations suggérées.
- 🚨 Bloquants (fautes de syntaxe, duplications critiques).
