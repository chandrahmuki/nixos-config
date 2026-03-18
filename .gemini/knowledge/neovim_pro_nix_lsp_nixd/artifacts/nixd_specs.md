# Spécifications : Neovim Pro Nix LSP (nixd)

L'utilisation de `nixd` permet une compréhension profonde de la structure du projet NixOS, offrant une documentation riche et une complétion intelligente des options que `nil` ne peut pas fournir sans configuration complexe.

## Composants Techniques

### 1. Serveur de Langage (nixd)
- **Remplacement** : `nil` par `nixd` pour une meilleure gestion des Flakes.
- **Configuration** : `nixd` est configuré pour évaluer `nixosConfigurations.muggy-nixos.options` et `home-manager.users.type.getSubOptions [ ]`.
- **Bénéfice** : Accès instantané à la documentation des options système et utilisateur directement dans Neovim via le protocole LSP.

### 2. Formatage Automatique (nixfmt)
- **Outil** : `nixfmt` (conforme à la RFC).
- **Intégration** : Configuré comme commande de formatage dans les `settings` de `nixd`.
- **Déclenchement** : Utilisation d'un `autocmd` Neovim sur l'événement `BufWritePre` pour garantir un code propre à chaque sauvegarde.

### 3. API Neovim Moderne (v0.11+)
- **Fonctions** : Utilisation de `vim.lsp.enable("nixd")` et `vim.lsp.config("nixd", { ... })`.
- **Avantage** : Code de configuration plus concis et performant, aligné sur les derniers standards de Neovim.

## Maintenance
Le binaire `nixd` et le formateur `nixfmt` sont installés de manière déclarative via Home Manager dans `modules/neovim.nix` (ou `antigravity.nix`). Leur mise à jour est pilotée par le `flake.lock`.
