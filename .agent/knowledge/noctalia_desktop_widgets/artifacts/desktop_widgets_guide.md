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
4. **Read-only `settings.json`**: Sur NixOS, ce fichier est un symlink vers le Nix Store. Les positions manuelles ne sont **pas persistées** sur disque. Il faut les capturer via IPC.

## IPC Debugging

```bash
# Lire l'état complet
noctalia-shell ipc call state all | jq .settings.desktopWidgets

# Lire les positions LIVE (seule source fiable)
noctalia-shell ipc call state all | jq -c '.settings.desktopWidgets.monitorWidgets[] | select(.name == "HDMI-A-1")'

# Lire les infos d'un moniteur
noctalia-shell ipc call state all | jq .state.display
```

> **IMPORTANT**: `settings.json` est read-only (symlink Nix Store). La seule façon de lire les positions manuelles est via l'IPC ci-dessus.

## Plugin Development

### Structure requise
```
~/.config/noctalia/plugins/<nom>/
├── manifest.json
└── DesktopWidget.qml   # Nom déclaré dans manifest.entryPoints.desktopWidget
```

### manifest.json
```json
{
  "id": "media-mixer",
  "name": "Media Mixer",
  "version": "1.0.0",
  "author": "...",
  "description": "...",
  "entryPoints": { "desktopWidget": "DesktopMediaMixer.qml" },
  "icon": "media-playlist"
}
```

### Pattern QML minimal
```qml
import qs.Modules.DesktopWidgets

DraggableDesktopWidget {
  id: root
  width: 300
  height: 80
  // widgetScale est une property de DraggableDesktopWidget
  // mais le scaling via poignées NE FONCTIONNE PAS pour les plugins
}
```

### Référencement dans Nix
ID: `plugin:<manifest.id>` — exemple: `plugin:media-mixer`.

## Limitations Plugins vs Widgets Intégrés

| Feature | Built-in | Plugin |
|---------|----------|--------|
| Drag (position) | ✅ | ✅ |
| Scale (poignées) | ✅ | ❌ |
| widgetScale property | ✅ (writable) | ❌ (lecture seule) |
| Hot-reload QML | ✅ | ✅ |
| showBackground | ✅ | ✅ |

> Les widgets intégrés (`DesktopClock`, `DesktopMediaPlayer`) utilisent `implicitWidth: X * widgetScale` et `width: implicitWidth`. Cette approche ne fonctionne pas pour les plugins car le scaling via les poignées de DraggableDesktopWidget ne modifie pas widgetScale pour les plugins.

## Built-in Widgets
- `Clock` — Horloge avec format configurable
- `MediaMini` / `DesktopMediaPlayer` — Lecteur média MPRIS
- `SystemMonitor` — CPU/RAM
- `Launcher` — App launcher
