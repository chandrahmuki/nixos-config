# Bluetooth NixOS Restoration (Post-DE Removal)

When removing a Desktop Environment (DE) like GNOME or KDE that handles Bluetooth services implicitly, Bluetooth support may disappear from the system. This guide covers how to restore it explicitly.

## 1. Explicit NixOS Configuration

Create a dedicated module (e.g., `modules/bluetooth.nix`) to ensure portability:

```nix
{ pkgs, ... }:

{
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Experimental = true;
        Enable = "Source,Sink,Media,Socket"; # Required for headset features
        AutoConnect = true;
        ControllerMode = "dual"; # Supports both classic and Low Energy (LE)
      };
    };
  };

  # Enables the bluetooth GUI management tool and tray applet
  services.blueman.enable = true;

  environment.systemPackages = with pkgs; [
    blueman
  ];
}
```

## 2. Desktop Environment Integration (Noctalia)

If using **Noctalia Shell**, the Bluetooth widget in the `ControlCenter` relies on the system-wide Bluetooth service.

### Troubleshooting Discovery
If the Bluetooth service was not active at session startup, the shell UI might not refresh the device list automatically.

**Fix**: Restart the Noctalia shell service as a user:
```bash
systemctl --user restart noctalia-shell.service
```

## 4. ZMK Keyboard Troubleshooting (e.g., Cradio)

ZMK keyboards often use a profile system. If pairing fails after an OS-side change, you must clear the profile on both sides.

### Procedure for Cradio/Ferris (standard layouts):
1.  **OS Side**: `bluetoothctl remove [MAC]`.
2.  **Keyboard Side**: Enter the **Tri Layer** (usually by holding both thumb keys).
    - Select the desired profile: `BT_SEL 0`, `BT_SEL 1`, etc.
    - Clear the current profile: `BT_CLR`.
3.  **Re-pair**: The keyboard should now be discoverable and pairable without errors.
