# Règles pour l'Assistant IA


## Git / Gestion de version
- Pour ce projet, après chaque modification fonctionnelle :
  - Exécuter `git add .`
  - Exécuter `git commit` avec un message descriptif approprié.

## Compilation et déploiement
- j´utilise `nos` pour compiler et déployer les modifications c'est un alias pour `nixos-rebuild switch`qui utilise le package nh "voir modules/nh.nix".

## Mise à jour du flake
- Pour tout mettre à jour SAUF le kernel CachyOS : `nix flake update --exclude nix-cachyos`
- Pour mettre à jour uniquement le kernel : `nix flake update nix-cachyos`
