# Transition vers le nouveau disque NVMe (Février 2026)

Cette note documente le passage d'une installation standard `ext4` vers une configuration optimisée `btrfs` sur le nouveau disque NVMe.

## Détails Techniques

### Système de Fichiers (BTRFS)
Nous avons abandonné `ext4` au profit de `btrfs` avec une structure de sous-volumes pour améliorer les performances et la maintenance :
- `@` : Racine du système.
- `@nix` : Stockage du store Nix (isolé pour les perfs).
- `@log` : Journaux système dans `/var/log`.
- `@home` : Données utilisateur.

### Optimisations SSD/NVMe
- **TRIM** : Activé via `services.fstrim.enable = true;` pour maintenir les performances du SSD sur le long terme.
- **ZRAM** : Utilisation de `zramSwap.enable = true;` pour le swap en RAM, évitant ainsi l'usure inutile du NVMe et améliorant la réactivité.
- **Kernel** : Utilisation du kernel `CachyOS` (bore) via `nix-cachyos` pour de meilleures performances globales et une meilleure gestion des entrées/sorties.

### Paramètres Kernel
- `amdgpu.gttsize=16384` : Augmentation de la taille GTT pour les performances graphiques (utile sur NVMe rapide).

## Ancienne Configuration (Avant transition)
- Racine sur `ext4`.
- Partition swap physique.
- UUID de boot : `95CA-4D08`.
- UUID racine : `fa83065a-443f-4836-9246-45983d2ebf49`.

## Nouvelle Configuration (Après transition)
- UUID de boot : `83F7-5789`.
- UUID BTRFS : `59f5b271-11c1-41f9-927d-ed3221a6b404`.
