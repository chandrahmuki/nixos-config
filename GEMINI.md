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

## Contexte LLM / Repomix / Diff
- J'utilise `repomix` pour avoir une vision globale du projet.
- Avant toute analyse globale, je devrais consulter `repomix-nixos-config.md` s'il existe.
- **Pour une analyse rapide des changements récents**, je dois prioriser `git log --stat` et `git show --stat` au lieu de scanner tous les fichiers un par un.
- Si des changements structurels majeurs sont faits, il est recommandé de mettre à jour le fichier repomix avec `repomix --output repomix-nixos-config.md`.
- J'utilise le workflow `/auto-doc` pour automatiser la documentation rapide.
- J'utilise le workflow `/full-index` pour les mises à jour majeures du contexte (Repomix).

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
- **Consommation de KI** : Avant de chercher quoi que ce soit, je vérifie si un KI existe déjà pour gagner du temps.
- **Création de KI** : Pour chaque nouveau module ou décision majeure, je dois créer un **Knowledge Item** (metadata.json + artifacts).
