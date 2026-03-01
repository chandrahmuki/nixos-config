# IBus & Xorg Optimization in NixOS (GNOME/Niri)

## Problem: Persistent IBus Notifications
On NixOS systems using GNOME (even with other compositors like Niri), IBus can be launched automatically, causing a persistent notification that cannot be dismissed easily if not properly configured.

## Solution 1: Total IBus Disabling
To completely silence IBus and prevent its autostart in GNOME:

1. **Disable Input Method**:
   ```nix
   i18n.inputMethod.enable = false;
   ```
2. **Exclude IBus from GNOME Packages**:
   Prevent GNOME from including IBus in the system profile.
   ```nix
   environment.gnome.excludePackages = [ pkgs.ibus ];
   ```
3. **Override GSettings for IM Module**:
   Force GTK to use a simple input method context to avoid looking for IBus.
   ```nix
   services.desktopManager.gnome.extraGSettingsOverrides = ''
     [org.gnome.desktop.interface]
     gtk-im-module='gtk-im-context-simple'
   '';
   ```

## Solution 2: Xorg Library Deprecation (nix-ld)
Old Xorg library names are being### Optimization nix-ld
To avoid "deprecated alias" warnings when using `nix-ld`, it is recommended to use the explicit `xorg.*` package names instead of the root-level aliases.

```nix
programs.nix-ld.libraries = [
  pkgs.xorg.libX11
  pkgs.xorg.libXext
  # ...
];
```
 deprecated or causing warnings. For `programs.nix-ld.libraries`, use PascalCase names without the `xorg.` prefix:

| Old Name (deprecated) | New Name (recommended) |
|-----------------------|-----------------------|
| `libx11`              | `libX11`              |
| `libxscrnsaver`       | `libXScrnSaver`       |
| `libxcomposite`       | `libXcomposite`       |
| `libxcursor`          | `libXcursor`          |
| `libxdamage`          | `libXdamage`          |
| `libxext`             | `libXext`             |
| `libxfixes`           | `libXfixes`           |
| `libxi`               | `libXi`               |
| `libxrandr`           | `libXrandr`           |
| `libxrender`          | `libXrender`          |
| `libxtst`             | `libXtst`             |

## Context: Niri Focus
These changes were implemented to clean up the environment when using **Niri** alongside GNOME components, ensuring a minimal and warning-free system.
