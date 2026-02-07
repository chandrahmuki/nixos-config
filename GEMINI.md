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
