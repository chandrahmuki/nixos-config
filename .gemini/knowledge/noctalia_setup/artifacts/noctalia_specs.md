# Noctalia Configuration Overview

Detailed technical specifications for the current Noctalia bar setup.

## 📐 Layout & Position
- **Monitor**: Locked to `DP-2` (AOC 2K Monitor).
- **Position**: `left` (vertical bar).
- **Style**: `floating` with `10px` margins.
- **Opacity**: `0.5` (50% background transparency).

## 🧩 Widgets (Minimalist)
The bar is configured to be extremely clean, omitting the traditional launcher.
- **Left**: Clock, SystemMonitor, ActiveWindow, MediaMini.
- **Center**: Workspace (Niri integration).
- **Right**: Tray, Battery, Volume, Brightness, ControlCenter.
- **Removed**: 
  - `Launcher`: Disabled in favor of keyboard shortcuts/fuzzel.
  - `NotificationHistory`: Fully disabled as per user preference.

## 🎨 Theming
- **Dynamic**: Uses internal Python engine to extract colors from `~/Pictures/wallpaper/wallpaper.png`.
- **Scheme**: Set to `vibrant` for maximum color saturation.
- **Dark Mode**: Enabled.

## 🔧 File References
- Main module: [/modules/noctalia.nix](file:///home/david/nixos-config/modules/noctalia.nix)
- Local settings cache: `~/.config/noctalia/settings.json`
