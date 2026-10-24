# VM de test headless

VM QEMU qui demarre la vraie configuration `muggy-nixos` sans fenetre, pour tester
focus, fenetres, Quickshell et applications sans toucher a la session reelle de
l'utilisateur. Fichiers : `scripts/vm-test.sh` (pilote) et `scripts/vm-test.nix`
(module ajoute via `extendModules`, tout est dans `virtualisation.vmVariant`).

Regle : la demarrer seulement le temps d'un test, puis toujours `stop`.

## Commandes

| Commande | Effet |
| --- | --- |
| `start` | build + boot, attend SSH puis Hyprland |
| `shot [nom]` | capture PNG (QMP `screendump`), affiche le chemin ; la lire avec l'outil de lecture d'images |
| `key KEY...` | touches via QMP, `meta_l-s` = Super maintenu + S |
| `mouse click X Y` / `drag X1 Y1 X2 Y2` / `move X Y` | pointeur, pixels de l'ecran invite (1280x800) |
| `exec CMD...` | commande en tant qu'utilisateur dans la VM (avec `HYPRLAND_INSTANCE_SIGNATURE`) |
| `hypr ARGS...` | `hyprctl` dans la VM |
| `reload` | redemarre Quickshell (le checkout 9p ne declenche pas le hot reload) |
| `log [unite]` | journal systeme, ou journal de l'unite utilisateur |
| `stop` | extinction et suppression de `/tmp/muggy-vm` |

## Setup

- **Etat** : `/tmp/muggy-vm` (disque qcow2, `qmp.sock`, `vnc.sock`, `console.log`, captures).
- **Ressources** : 8 Go de RAM, 6 coeurs, disque 16 Go, `graphics = false`.
- **Affichage** : `-vga std` + `-vnc unix:...`. Avec virtio-gpu headless, `screendump` est
  noir et `grim` se bloque ; ne pas changer sans retester `shot`.
- **Entrees** : `-device usb-kbd`, QMP sur `qmp.sock`.
- **SSH** : hote `127.0.0.1:2222`, utilisateur `david`, mot de passe `vm` fourni par
  `SSH_ASKPASS` (aucun vrai secret).
- **Checkout** : partage 9p en lecture seule monte sur `/home/david/nixos-config`
  (Home-Manager y lie la config Quickshell). Modifier le checkout hote suffit, puis `reload`.
- **Noyau** : `linuxPackages` generique, modules et `scx` desactives, pilotes xserver vides.
- **Session** : greetd attend `home-manager-david.service`, puis lance Hyprland via uwsm
  (sinon `hyprland.lua` n'existe pas encore et Quickshell ne demarre pas).
- **Duree** : le premier `start` peut depasser 10 minutes (evaluation et build de toute la
  configuration) ; le lancer en arriere-plan. Les demarrages suivants sont plus rapides.

## Pieges connus (mesures le 2026-10-24)

- `exec` exporte `WAYLAND_DISPLAY` (corrige le 2026-10-24). Lancer une application graphique :
  `scripts/vm-test.sh exec '(setsid APP >/tmp/app.log 2>&1 &)'`.
- **Helium** lance sans `--ozone-platform=wayland` part en X11 et sort avec
  `Missing X server or $DISPLAY`. Avec le flag, la fenetre s'affiche.
- Helium affiche aussi `Requested GL implementation (gl=egl-gles2,angle=none) not found` :
  le flag `--use-gl=egl` n'est pas accepte par cette version (retire dans le working tree
  de `aspects/helium.nix`, non verifie comme cause unique). WebGL reste indisponible
  (pas de GPU 3D) ; les erreurs VA-API (`radeonsi_drv_video.so`) sont sans effet sur l'affichage.
- Helium ouvre sur un profil neuf un prompt `gcr-prompter` « Choose password for new
  keyring » : la fenetre masque le navigateur. Le fermer (`pkill gcr-prompter`) avant la capture.
- **Zen** (`zen-beta`) s'affiche (ecran « Welcome ») sans flag particulier ; les avertissements
  UPower sont sans effet (pas de batterie dans la VM).
- Rien de ce qui est dans la VM ne persiste : profils et trousseau repartent de zero a chaque `start`.

## Parcours type

```sh
scripts/vm-test.sh start                 # en arriere-plan si possible
scripts/vm-test.sh exec '(setsid zen-beta >/tmp/zen.log 2>&1 &)'
scripts/vm-test.sh shot zen              # puis lire le PNG
scripts/vm-test.sh hypr clients          # verifier classe et titre de la fenetre
scripts/vm-test.sh stop
```
