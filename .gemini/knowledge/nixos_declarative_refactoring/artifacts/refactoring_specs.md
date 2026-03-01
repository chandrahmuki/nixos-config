# NixOS Declarative Refactoring

## Problème : La Configuration Brittle (Fragile)
Dans une configuration NixOS naissante, il est courant de voir des chemins hardcodés ou des variables (comme le `hostname` ou le `username`) répétées dans de nombreux fichiers.
Cela entraîne des problèmes majeurs :
1.  **Impossibilité de partager le code** : Pour installer la configuration sur une autre machine, il faut utiliser des scripts complexes (`sed`) pour modifier le code source.
2.  **Manque de pureté** : La modification dynamique des fichiers sources lors de l'installation brise le concept déclaratif de Nix.
3.  **Confusion des dossiers** : Le code source de paquets locaux est souvent mélangé avec des scripts utilitaires dans un dossier `scripts/`.

## Solution : Variables Centralisées via `specialArgs`

### 1. Déclaration dans `flake.nix`
La bonne pratique consiste à définir toutes les variables globales (nom d'utilisateur, nom de machine) directement au niveau des `outputs` du `flake.nix`, et à les injecter partout via `specialArgs` (pour NixOS) et `extraSpecialArgs` (pour Home Manager).

```nix
outputs = { self, nixpkgs, home-manager, ... }@inputs:
let
  username = "david";
  hostname = "muggy-nixos"; # Définition unique
in
{
  nixosConfigurations.${hostname} = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs username hostname; }; # Injection
    modules = [
      ./hosts/system/default.nix
      # ...
      home-manager.nixosModules.home-manager
      {
        home-manager.extraSpecialArgs = { inherit inputs username hostname; }; # Injection HM
        home-manager.users.${username} = import ./home.nix;
      }
    ];
  };
};
```

### 2. Consommation dans les Modules
Dans n'importe quel module (`hosts/system/default.nix`, `modules/terminal.nix`, etc.), on récupère simplement la variable en argument.

```nix
# hosts/system/default.nix
{ config, pkgs, hostname, ... }: # <-- Récupération
{
  networking.hostName = hostname; # <-- Utilisation
}
```

### 3. Agnosticisme des chemins (Generic Pathing)
Pour que le `flake.nix` reste invariant (sans avoir à utiliser `sed` sur les chemins d'import), il faut renommer les dossiers d'hôtes spécifiques (ex: `hosts/muggy-nixos/`) en noms génériques (ex: `hosts/system/`).
Ainsi l'import `./hosts/system/default.nix` reste toujours valide, peu importe le nom réel de la machine.

## Structuration des Paquets Locaux
Un dossier `scripts/` ne doit contenir que des scripts shell (comme `install.sh`).
Si un script devient un vrai projet (ex: Go, Rust) qui est buildé via un paquet Nix (ex: `buildGoModule`), son code source DOIT être placé dans le dossier du paquet (ex: `pkgs/mon-app/src/`) pour garantir l'encapsulation.

```nix
# pkgs/mon-app/default.nix
buildGoModule {
  pname = "mon-app";
  src = ./src; # Au lieu de pointer vers un dossier global lointain
}
```

## Bénéfices
- **Portabilité absolue** : L'installation sur une nouvelle machine nécessite la modification d'une seule ligne dans `flake.nix`.
- **Pureté Nix** : Plus aucune modification de fichier par des commandes impératives (pas de `sed` massif).
- **Propreté de l'arbre** : Séparation claire entre scripts éphémères et code source packagé.
