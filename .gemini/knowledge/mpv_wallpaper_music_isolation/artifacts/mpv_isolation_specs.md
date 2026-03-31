# Spécifications Techniques : Isolation MPV (Wallpaper vs Musique)

Ce document détaille la mise en place d'un système de fond d'écran animé performant et sa cohabitation avec la lecture audio sur NixOS.

## 1. Problématique Initiale
- Les fichiers **WebP animés** sont mal gérés par `mpv` (moteur de `mpvpaper`), provoquant des erreurs de décodage (`ANMF chunks skipping`) et une consommation CPU inutile.
- Les commandes `pkill mpv` utilisées dans les scripts de musique tuaient accidentellement l'instance du fond d'écran.
- Les instances entraient en conflit pour l'accès aux ressources GPU (Vulkan/VA-API).

## 2. Solutions Appliquées

### 2.1 Conversion des Formats (WebP → GIF)
Pour `mpvpaper`, le format **GIF** est bien plus efficace que le WebP animé.
- **Outil** : `ImageMagick` (magick).
- **Commande** : `magick input.webp output.gif`.
- **Résultat** : Utilisation CPU proche de 0% et fluidité parfaite sur tous les écrans.

### 2.2 Isolation par IPC (Inter-Process Communication)
Au lieu de relancer une instance `mpv` à chaque changement de morceau, on utilise un socket de contrôle.
- **Socket** : `/tmp/mpv-music.sock`.
- **Mécanique** :
  1. Le script vérifie si le socket existe (`if test -S $SOCKET`).
  2. Si oui, il envoie la commande `loadfile` via `socat`.
  3. Si non, il lance `mpv` avec `--input-ipc-server=$SOCKET`.

### 2.3 Isolation des Ressources GPU
Pour éviter les conflits matériels :
- **Musique** : Forcée en mode "audio pur" sans sortie vidéo (`--vo=null`) et sans accélération matérielle (`--hwdec=no`).
- **Wallpaper** : Dispose de l'accès exclusif au GPU via `libmpv`.

## 3. Implémentation NixOS

### Alias mpno (Fish)
```fish
set -l SOCKET /tmp/mpv-music.sock
set -l FILE $argv[1]
if test -S $SOCKET
    echo "{\"command\": [\"loadfile\", \"$FILE\"]}" | socat - $SOCKET
else
    mpv --no-video --ao=pipewire --vo=null --hwdec=no --input-ipc-server=$SOCKET "$FILE" &
    disown
end
notify-send -t 2000 "🎵 Musique" (basename "$FILE")
```

### Script music-menu (Bash)
Même logique IPC intégrée au sélecteur Walker pour garantir qu'aucune instance `mpvpaper` ne soit fermée par erreur.

## 4. Maintenance
- **Dépendances** : `mpvpaper`, `socat`, `libnotify`.
- **Nettoyage** : Pas de `pkill mpv` global dans les scripts.
