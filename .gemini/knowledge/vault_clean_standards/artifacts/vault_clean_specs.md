# Vault-Clean Standards

Ce document définit les standards de sécurité et d'anonymisation pour le dépôt `nixos-config`. Aucun commit ne doit déroger à ces règles pour préserver la confidentialité du développeur.

## 1. Anonymisation des Chemins (PII)

**INTERDICTION** d'utiliser des chemins absolus vers le home utilisateur.
- **Mauvais** : `/home/david/nixos-config/`
- **Bon (Nix)** : `${config.home.homeDirectory}/nixos-config/`
- **Bon (Shell/JSON)** : `~/nixos-config/` ou `$HOME/nixos-config/`

**REMPLACEMENT DES IDENTITÉS** :
- Les noms d'utilisateur ("David") et les emails ("david@...") ne doivent jamais apparaître en dur.
- Utiliser des variables SOPS ou des placeholders génériques si nécessaire.

## 2. Isolation des Outils IA et Reproductibilité

Pour garantir une expérience fluide tout en protégeant les stratégies sensibles :
- **SUIVI GIT (Mandatoire)** : `flake.lock` doit être committé pour assurer la reproductibilité et éviter les téléchargements d'inputs à chaque build.
- **STRICTEMENT EXCLUS** via `.gitignore` :
    - `.gemini/` (Mémoire, Skills, Workflows)
    - `.agent/` (Configuration de l'agent, Settings)
    - `.planning/` (Roadmaps, State, Requirements)
    - `repomix-*.md` (Indexation globale du code)

## 3. Gestion des Secrets (SOPS-Nix)

Toute donnée sensible doit être chiffrée via **SOPS** :
- Fichier maître : `secrets/secrets.yaml`.
- Déchiffrement : Via clé AGE dérivée de la clé SSH (`id_ed25519`).
- Injection : Les clés API sont chargées dynamiquement par le shell (Fish) depuis `/run/user/1000/secrets/` ou des liens symboliques SOPS, **jamais** écrites dans les fichiers `.nix`.

## 4. Maintenance de l'Historique

Si une fuite accidentelle se produit :
1. Corriger immédiatement le fichier (`replace`).
2. Purger l'historique Git (Squash ou `git filter-repo`) avant de push.
3. Rotation immédiate de la clé API compromise.

---
*Ce standard est maintenu par le workflow Vault-Clean.*
