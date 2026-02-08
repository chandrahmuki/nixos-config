# 🌐 Gestion des Extensions Brave sur NixOS

Cette fiche explique comment sont gérées les extensions dans Brave pour garantir leur présence et leur sécurité.

## Mécanisme de Politiques Système
Plutôt que d'utiliser une gestion par profil utilisateur (souvent instable pour le forçage), nous utilisons les politiques **Chromium** globales.

### Fichiers impliqués
- `modules/brave-system.nix` : Contient la liste des extensions forcées.
- `hosts/muggy-nixos/default.nix` : Importe la configuration système.

### Extensions Forcées
Actuellement, les extensions suivantes sont installées d'office et ne peuvent pas être désactivées par l'utilisateur :
- **Bitwarden** (Gestionnaire de mots de passe)
- **uBlock Origin** (Bloqueur de publicités)

## Pourquoi ce choix ?
Brave étant basé sur Chromium, il lit les fichiers de politiques situés dans `/etc/chromium/policies/managed/`. C'est la méthode recommandée sur NixOS pour assurer une configuration immuable et robuste.

## Ajouter une extension
1. Récupérer l'ID de l'extension sur le Chrome Web Store.
2. L'ajouter dans `modules/brave-system.nix` sous la forme :
   `"ID;https://clients2.google.com/service/update2/crx"`
