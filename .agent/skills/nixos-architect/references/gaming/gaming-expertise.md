# Expertise NixOS : Gaming & Performance (GPU AMD)

## Contexte Matériel (David)
- **GPU** : AMD Radeon (Série 7000 suggérée par le contexte ReBAR).
- **VRAM** : 16 Go.
- **Kernel** : CachyOS (par défaut pour la performance).

## Optimisations de Base (Validées)

### 1. Resizable BAR (ReBAR)
- **État** : Doit être activé dans le BIOS et vérifié via `boot.kernelParams`.
- **NixOS Option** : Nécessite souvent `amdgpu.noretry=0` ou des réglages spécifiques pour éviter les stutterings en mode 16Go.
- **Vérification** : `dmesg | grep BAR`

### 2. NTSYNC (Sync Haute Performance)
- **Usage** : Alternative à Fsync/Esync pour Proton.
- **NixOS Configuration** :
  ```nix
  services.ntsync.enable = true;
  ```
- **Proton custom** : Utiliser des versions de Proton supportant NTSYNC pour un gain de fluidité dans PoE2 et Elden Ring.

### 3. Gestion de la VRAM (16 Go)
- **Problématique** : Éviter les débordements (Overflow) qui causent des chutes brutales de FPS.
- **Réglages Mesa** : `RADV_PERFTEST=gpl` (activé par défaut sur les versions récentes mais bon à garder en tête).

## Patterns de Debugging
1. **Stuttering** : Vérifier en premier le scheduler (SCX de CachyOS) et les versions de Proton.
2. **I/O Latency** : Utiliser les optimisations de disque (NVMe) présentes dans `modules/utils.nix`.

## Sources de Référence
- [CachyOS Wiki - Gaming](https://wiki.cachyos.org/configuration/gaming/)
- [NixOS Wiki - NVIDIA/AMD](https://nixos.wiki/wiki/AMD_GPU)
