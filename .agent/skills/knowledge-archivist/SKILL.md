---
name: knowledge-archivist
description: Focus 100% sur la documentation et les Knowledge Items (KIs). Garant de la validité et de la structure de la mémoire IA.
---

# Skill: Knowledge Archivist

Ce skill définit les standards de capitalisation du savoir pour le rôle d'Archiviste dans le workflow Relais Triple.

## Objectifs
- Transformer les commits techniques en apprentissages structurés (Knowledge Items).
- Garantir un format JSON strict pour les fichiers `metadata.json`.
- Maintenir la cohérence du graphe de connaissances via des liens inter-KIs.
- Assurer que les solutions techniques (spécifications) sont reproductibles.

## Structure d'un Knowledge Item (KI)

Chaque KI doit être situé dans `~/.gemini/antigravity/knowledge/[nom_du_ki]/` et contenir :

### 1. `metadata.json`
- **Champs obligatoires** : `title`, `summary`, `created_at`, `updated_at`, `categories`, `references`.
- **Validation** : Le JSON doit être valide (pas de virgules traînantes).
- **Format Date** : ISO 8601 UTC (ex: `2026-02-16T08:32:00Z`).

### 2. `artifacts/` (Dossier)
Contient les spécifications techniques (généralement `[nom]_specs.md`).
- Utiliser des titres H1/H2 clairs.
- Inclure des blocs de code NixOS testés.
- Ajouter des tables comparatives si nécessaire.

## Procédure d'Archivage

1. **Vérification de l'existence** : Avant de créer, vérifier si un KI similaire existe déjà. Si oui, le mettre à jour.
2. **Extraction du commit** : Analyser `git show --stat` pour identifier les fichiers clés et la logique métier.
3. **Rédaction des Specs** : Concentrer le savoir sur le "POURQUOI" et le "COMMENT" (valeur ajoutée par rapport au code brut).
4. **Mise à jour du lock** : S'assurer que le nouveau KI est mentionné dans la mémoire globale (via notification ou update du lock si géré).

## Qualité
- Langue : Français (pour les descriptions) et Anglais (pour les termes techniques/metadata).
- Style : Concis, chirurgical, sans placeholders.
