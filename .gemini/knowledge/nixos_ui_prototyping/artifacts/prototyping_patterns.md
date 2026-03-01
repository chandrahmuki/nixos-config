# NixOS UI Prototyping (Mutable State)

## Le Problème du Read-Only
Dans NixOS (via Home Manager), les configurations (`settings = { ... }`) génèrent des fichiers figés dans le `/nix/store/`.
Cela pose un problème majeur pour les UI (comme Noctalia, Yazi, Gemini CLI) qui ont besoin d'écrire leur propre "état" (ex: redimensionnement de widget à la souris, préférences dynamiques). Un fichier read-only bloque l'application avec une erreur "Permission Denied".

## Stratégie 1 : L'Environnement Natif (Noctalia)
La méthode la plus propre. Si l'application prévoit une variable d'environnement pour forcer le chemin de sa configuration, on l'utilise pour pointer directement vers un fichier de notre dépôt Git.

**Exemple (Noctalia) :**
Plutôt que d'utiliser l'option Nix `programs.noctalia-shell.settings`, on crée un `noctalia-settings.json` dans `~/nixos-config/generated/`.
Puis on injecte la variable dans la session :

```nix
home.sessionVariables = {
  NOCTALIA_SETTINGS_FILE = "${config.home.homeDirectory}/nixos-config/generated/noctalia-settings.json";
};
```
**Résultat :** L'UI peut réécrire son fichier en direct, et les changements (ex: positions X/Y des widgets) sont trackés par Git pour être commités. La reproductibilité est maintenue car le fichier vit dans le dépôt.

## Stratégie 2 : Le Symlink Out-of-Store (Gemini / Yazi)
Si l'application ne propose pas de variable d'environnement (elle cherche toujours dans `~/.config/app/settings.json`), on utilise `mkOutOfStoreSymlink`.

**Exemple (Gemini CLI) :**
```nix
home.file."nixos-config/.gemini/settings.json".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-config/.agent/gemini-settings.json";
```
**Attention :** Le fichier cible (`.agent/gemini-settings.json`) DOIT exister physiquement lors du switch Home Manager, sinon le lien sera cassé.

## Le Workflow "Laboratoire vs Gel" (Freezing)
Ces méthodes cassent la pureté déclarative stricte de Nix, mais sont indispensables pour le prototypage visuel.
La "bonne pratique" consiste à :
1. **Laboratoire** : Utiliser ces bypass pour placer ses widgets ou régler ses thèmes à la souris.
2. **Gel (Freeze)** : Une fois le setup visuel finalisé, on lit les valeurs générées dans le fichier mutable, on les réécrit "en dur" dans le `.nix` (ex: `desktopWidgets`), et on supprime le bypass pour rendre le système 100% pur à nouveau.
