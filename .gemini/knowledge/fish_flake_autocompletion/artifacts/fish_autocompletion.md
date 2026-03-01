# Fish Autocompletion via `flake.lock`

Cette technique permet d'ajouter une complétion intelligente pour les entrées d'un flake Nix sans ralentir le shell.

## Problématique
La commande `nix flake update` demande souvent le nom d'un input (ex: `nixpkgs`). Taper ces noms manuellement est fastidieux et sujet aux erreurs.

## Solution Technique
Utiliser la commande `complete` de Fish associée à `jq` pour extraire les clés du fichier `flake.lock`.

### Implémentation NixOS
Dans votre configuration Home Manager ou NixOS :

```nix
programs.fish.interactiveShellInit = ''
  # Complétion pour nfu (nix flake update)
  # On extrait les inputs du flake.lock et on exclut ceux déjà présents sur la ligne de commande
  complete -c nfu -f -a "(
    if test -f flake.lock
      set -l inputs (cat flake.lock | jq -r '.nodes.root.inputs | keys[]' 2>/dev/null)
      set -l current_args (commandline -opc)
      for i in \$inputs
        if not contains \$i \$current_args
          echo \$i
        end
      end
    end
  )"
'';
```

### Dépendances
- `jq` : Nécessaire pour parser le JSON du lockfile.
- `fish` : Supporte nativement l'exécution de commandes dans les arguments de complétion via `(...)`.

## Avantages
- **Vitesse** : Parser un fichier local est instantané (comparé à `nix flake metadata`).
- **Fiabilité** : Ne suggère que les inputs réellement présents dans le projet actuel.
- **Portabilité** : Fonctionne dans n'importe quel dépôt Git contenant un flake Nix.
