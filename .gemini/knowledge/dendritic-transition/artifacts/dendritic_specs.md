# Spécifications Techniques : Transition Dendritic

L'architecture **Dendritic** (en référence aux branches d'un neurone) vise à rendre chaque fonctionnalité de la configuration NixOS totalement autonome, englobant à la fois les paramètres système (NixOS) et les paramètres utilisateur (Home Manager).

## 1. Principes Fondamentaux

- **Auto-Contenance** : Un module (ex: `yazi.nix`) doit contenir TOUTE la logique liée à Yazi. Si on retire le fichier du dossier `modules/`, la fonctionnalité disparaît proprement du système et du home utilisateur sans laisser d'erreurs d'import.
- **Inversion de Contrôle** : Ce n'est plus `home.nix` qui importe ses modules, mais les modules système qui "injectent" leur configuration dans le home manager des utilisateurs via `home-manager.users.${username}`.
- **Abstraction du Chemin** : Utilisation systématique de `/home/${username}/` pour garantir la portabilité et éviter les récursions infinies lors de l'évaluation des attributs Home Manager.

## 2. Structure d'un Module Dendritic

```nix
{ config, lib, pkgs, username, inputs, ... }:

{
  # --- LOGIQUE NIXOS (Système) ---
  environment.systemPackages = [ pkgs.foo ];
  
  # --- LOGIQUE HOME MANAGER (Utilisateur) ---
  home-manager.users.${username} = { config, lib, ... }: {
    programs.foo = {
      enable = true;
      # ... config HM
    };
  };
}
```

## 3. Implémentation de l'Auto-Scan

Le fichier `modules/default.nix` utilise une fonction récursive pour importer automatiquement tout fichier `.nix` présent dans le dossier :

```nix
scanModules = path:
  # ... logique de filtrage des fichiers .nix
  # ... récursion dans les sous-dossiers
```

Cela permet d'ajouter une nouvelle fonctionnalité simplement en déposant un fichier dans `modules/`.

## 4. Impact sur les fichiers Racines

- **flake.nix** : Ne contient plus que les inputs et les déclarations de hosts. Les imports de modules tiers (ex: `niri.nixosModules.niri`) sont déplacés dans les modules de fonctionnalités correspondants.
- **home.nix** : Devient un fichier minimal (déclaration du `stateVersion` et du `username`). Il ne contient plus aucun import manuel.

## 5. Résolution de Conflits (Cas Particuliers)

Certains flakes (comme `niri-flake`) gèrent leur propre intégration Home Manager. Dans ce cas, il faut importer le module NixOS du flake au niveau système et configurer `programs.niri.settings` dans le bloc HM sans ré-importer le module HM manuellement pour éviter les collisions d'options (`finalConfig`).
