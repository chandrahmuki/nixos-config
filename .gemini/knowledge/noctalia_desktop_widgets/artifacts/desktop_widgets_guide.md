# Noctalia Desktop Widgets Guide

Noctalia Shell (Quickshell-based) supports desktop widgets that live on the wallpaper. This guide covers configuration, plugin development, and debugging.

## Configuration (Nix/Home Manager)

Key: `desktopWidgets` — property `name` (not `monitor`) for monitor targeting.

```nix
programs.noctalia-shell.settings = {
  desktopWidgets = {
    enabled = true;
    monitorWidgets = [
      {
        name = "HDMI-A-1"; # Must match `niri msg outputs`
        widgets = [
          { id = "Clock"; x = 33; y = 45; scale = 0.53; format = "HH:mm\nd MMMM yyyy"; showBackground = true; }
          { id = "plugin:media-mixer"; x = 134; y = 52; scale = 1; }
        ];
      }
    ];
  };
};
```

## Important Behaviors

1. **Monitor Names**: Must match Wayland output name (`DP-2`, `HDMI-A-1`).
2. **First-time Visibility**: New widgets are invisible until positioned via Edit Mode.
3. **Edit Mode**: Control Center → Desktop Widgets Edit Mode → Drag/resize.
4. **Read-only `settings.json`**: Par défaut sur NixOS, le fichier est un symlink vers le Nix Store. Les positions manuelles ne sont **pas persistées** sur disque. (Voir le KI `nixos_ui_prototyping` pour la solution).

## MPRIS vs PipeWire (Audio Stream Matching)

Lorsque vous créez un widget audio complexe (ex: un Mixer qui contrôle le volume PipeWire ET l'état de lecture MPRIS), vous devez lier les deux services de Noctalia : `AudioService` (PipeWire) et `Mpris` (Contrôles).

### Le Piège du Nommage (MPV)
Certains lecteurs vidéo comme `mpv` envoient parfois des métadonnées vides (`null`) au niveau supérieur de PipeWire (`node.name` ou `node.description`).
Pour garantir un matching MPRIS parfait, extrayez les propriétés profondes de PipeWire :

```javascript
// Extraction robuste du nom de l'application depuis le flux PipeWire
var desc = (stream.description || stream.name || "").toLowerCase();
if (stream.properties) {
  var appName = (stream.properties["application.name"] || stream.properties["application.process.binary"] || "").toLowerCase();
  if (appName) desc += " " + appName;
}

// Recherche du lecteur MPRIS correspondant
var matchedPlayer = null;
for (var i = 0; i < players.length; i++) {
  var p = players[i];
  var id = (p.identity || p.name || p.busName || "").toLowerCase();
  
  // Toujours s'assurer que l'ID n'est pas vide pour éviter les faux-positifs !
  if (id !== "" && (desc.includes(id) || id.includes(desc))) {
    matchedPlayer = p;
    break;
  }
}
```

### Isolation du Global State
Le `MediaService` natif de Noctalia possède un timer (toutes les 2 secondes) qui force le focus sur le lecteur actuellement en lecture.
Si un widget doit cibler un lecteur en pause (ex: `mpv`) pendant qu'un autre joue (ex: `youtube`), le widget DOIT importer `Quickshell.Services.Mpris` directement et gérer son propre `currentMprisPlayer`, sans faire appel aux fonctions globales de `MediaService`, sous peine de voir le focus "sauter" sur le lecteur actif toutes les 2 secondes.

## IPC Debugging

```bash
# Lire l'état complet
noctalia-shell ipc call state all | jq .settings.desktopWidgets

# Lire les positions LIVE (seule source fiable)
noctalia-shell ipc call state all | jq -c '.settings.desktopWidgets.monitorWidgets[] | select(.name == "HDMI-A-1")'
```

## Built-in Widgets
- `Clock` — Horloge avec format configurable
- `MediaMini` / `DesktopMediaPlayer` — Lecteur média MPRIS
- `SystemMonitor` — CPU/RAM
- `Launcher` — App launcher
