# Règles pour l'Assistant IA

> [!NOTE]
> Je dispose de compétences spécialisées (Skills) situées dans `.agent/skills/`. Elles complètent ces règles de base.


## Git / Gestion de version
- Pour ce projet, après chaque modification fonctionnelle :
  - Exécuter `git add .`
  - Exécuter `git commit` avec un message descriptif approprié.

## Compilation et déploiement
- J'utilise `nos` pour compiler et déployer les modifications. C'est un alias pour `nh os switch` (voir `modules/nh.nix`).
- **Important** : Je lance `nos` moi-même dans un terminal externe. Ne pas l'exécuter depuis l'éditeur (nécessite sudo).

## Mise à jour du flake
- Pour tout mettre à jour SAUF le kernel CachyOS : `nix flake update nixpkgs home-manager niri noctalia antigravity`
- Pour mettre à jour uniquement le kernel : `nix flake update nix-cachyos`

## Commentaires et Clarté
- **Toujours commenter le code** : Chaque ajout ou modification complexe doit être accompagné de commentaires explicatifs pour faciliter la compréhension de la configuration.

## Recherche et Stratégie (NixOS / Nixpkgs)
- **Priorité aux Outils MCP** : Pour toute recherche sur des options NixOS, des packages nixpkgs ou des paramètres Home Manager, utiliser **OBLIGATOIREMENT** l'outil `mcp_nix-search_nix` au lieu de recherches web génériques.
- **Utilisation de Fetch** : Si une recherche web est nécessaire malgré tout, utiliser l'outil de fetch (ou `mcp_fetch`) pour extraire le contenu proprement.
- **Précision** : Ne jamais deviner une option. Toujours la vérifier via le MCP pour garantir la compatibilité avec la version système.

## Contexte LLM / Repomix / Diff
- J'utilise `repomix` pour avoir une vision globale du projet.
- Avant toute analyse globale, je devrais consulter `repomix-nixos-config.md` s'il existe.
- **Pour une analyse rapide des changements récents**, je dois prioriser `git log --stat` et `git show --stat` au lieu de scanner tous les fichiers un par un.
- Si des changements structurels majeurs sont faits, il est recommandé de mettre à jour le fichier repomix avec `repomix --output repomix-nixos-config.md`.
- J'utilise le workflow `/auto-doc` pour automatiser la documentation rapide.
- J'utilise le workflow `/full-index` pour les mises à jour majeures du contexte (Repomix).

## Répartition des Rôles (Relais Triple)
- **Codeur (Toi)** : Focus 100% sur l'implémentation et la vérification fonctionnelle (tests).
- **Auditeur (Revue)** : Focus 100% sur la qualité, la propreté du code (Audit) et la conformité aux règles. Ne fait aucune modification.
- **Archiviste (Savoir)** : Focus 100% sur la documentation et les **Knowledge Items**.
- **Mode Relais** : Le Codeur passe le témoin à l'Auditeur ou à l'Archiviste via le workflow `/auto-doc`.

## Vitesse & Focus Chirurgical (Anti-Lag)
- **Priorité aux outils natifs** : J'utilise `list_dir` et `view_file` au lieu de `ls` ou `cat` dans le terminal. C'est instantané et ça ne "bloque" jamais.
- **Budget Turn-R/W** : Une tâche de documentation ne doit pas dépasser 5-10 appels d'outils. Si l'analyse devient complexe, je demande d'abord.
- **Zéro historique profond** : Interdiction de naviguer dans le `git log` au-delà du dernier commit (`-n 1`) sans demande explicite. 
- **Surgical Metadata Only** : Dans un workflow `/auto-doc`, je me contente de `git show --stat`. Je ne lis QUE les fichiers modifiés.
- **Pas de boucles infinies** : Si une commande ne répond pas après 2 tentatives de `command_status`, je demande l'avis de l'utilisateur au lieu de bloquer.

## Gestion du Savoir (Knowledge)
- **Différence Doc vs Knowledge** : 
    - `./docs/` est pour les humains (fiches, guides).
    - `~/.gemini/antigravity/knowledge/` est pour la mémoire IA (Knowledge Items).
- **Consommation Obligatoire** : Avant de rédiger quoi que ce soit, **VÉRIFIER** si un KI existe déjà sur le sujet pour le mettre à jour au lieu d'en créer un nouveau.
- **Priorité KI** : Pour toute modification technique structurelle, la création/mise à jour d'un **Knowledge Item** est LA priorité absolue par rapport à la doc Markdown classique.
