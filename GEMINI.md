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
- Pour tout mettre à jour SAUF le kernel CachyOS : `nix flake update --exclude nix-cachyos`
- Pour mettre à jour uniquement le kernel : `nix flake update nix-cachyos`

## Commentaires et Clarté
- **Toujours commenter le code** : Chaque ajout ou modification complexe doit être accompagné de commentaires explicatifs pour faciliter la compréhension de la configuration.
