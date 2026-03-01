# KI: Sécurité des Clés API et État d'Intégration Antigravity

## Contexte
Ce KI documente l'architecture de gestion des secrets et le retour d'expérience sur l'IDE Google Antigravity.

## Architecture des Secrets (sops-nix)
- **Fichier Source** : `secrets/secrets.yaml` (chiffré via `age`).
- **Mécanisme** : `sops-nix` déchiffre les clés dans `~/.config/antigravity/` (`gemini_api_key`, `github_token`).
- **Chargement Shell (Fish)** : 
    - Les clés sont injectées dynamiquement dans `modules/terminal.nix` via `interactiveShellInit`.
    - Variables exportées : `GEMINI_API_KEY`, `GOOGLE_API_KEY`.
    - **Raison** : `home.sessionVariables` ne supporte pas l'expansion de commande `$(cat ...)` avec Fish.

## État de l'IDE Antigravity
- **Problématique** : Antigravity (v1.19.x) impose Vertex AI (Enterprise) pour l'IA agentique.
- **Symptôme** : Rejet des projets personnels ("pas une team").
- **Statut** : IA agentique désactivée (incompatible clés Consumer).

## Outils Validés
- **Gemini CLI** : Fonctionnel.
- **OpenCode** : Fonctionnel.
