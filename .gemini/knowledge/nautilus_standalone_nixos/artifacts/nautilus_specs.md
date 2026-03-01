# Nautilus Standalone on NixOS

This guide explains how to install and configure Nautilus (GNOME Files) as a standalone file manager on a non-GNOME environment (like Niri or Sway) while maintaining full functionality (thumbnails, drive mounting, previews).

## Hardware & System Integration

Nautilus relies on several back-end services to provide a "GNOME-like" experience.

### Core Dependencies

| Service | Feature | NixOS Option |
|---------|---------|--------------|
| **GVfs** | Sidebar drives, trash, network mounts | `services.gvfs.enable = true;` |
| **Tumbler** | Image/Video thumbnails | `services.tumbler.enable = true;` |
| **Sushi** | Quick file preview (Spacebar) | `services.gnome.sushi.enable = true;` |

## Configuration Example

```nix
{ pkgs, ... }:

{
  # 1. Integration Services
  services.gvfs.enable = true;
  services.tumbler.enable = true;
  services.gnome.sushi.enable = true;

  # 2. Main Package
  environment.systemPackages = with pkgs; [
    nautilus
  ];

  # 3. Optional: Adwaita settings for consistent look
  # Usually handled via Home Manager dconf settings.
}
```

## Troubleshooting

### Sidebar empty (no Trash or Drives)
Ensure `services.gvfs.enable` is set to `true`. Without GVfs, Nautilus behaves as a very basic directory browser.

### No Thumbnails
Ensure `services.tumbler.enable` is present. You may also need `pkgs.ffmpegthumbnailer` for video support if not included by default.

### Spacebar doesn't do anything
Verify `services.gnome.sushi.enable` is true. Note that Sushi might require `wayland` to be properly configured if running in a Wayland compositor.
