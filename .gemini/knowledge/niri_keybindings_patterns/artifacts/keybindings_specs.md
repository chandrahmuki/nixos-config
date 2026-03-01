# Niri Keybinding Patterns & Troubleshooting

Technical specifications for defining robust keybindings in the Niri compositor using Home Manager.

## 1. The `spawn` Action Syntax

Niri's `spawn` action does **not** use a shell to execute commands. This means that if you provide a single string with spaces, Niri will look for a binary with that exact name (including the spaces).

### ❌ Incorrect (Single String)
```nix
"Mod+Ctrl+p".action = spawn "playerctl play-pause";
```
*Result: Niri looks for an executable titled "playerctl play-pause".*

### ✅ Correct (List Syntax)
Arguments must be passed as a list of separate strings.
```nix
"Mod+Ctrl+p".action = spawn [ "playerctl" "play-pause" ];
```

## 2. XKB Keysym Names

Niri uses XKB keysym names. While some capitalized names work, it is highly recommended to use **lowercase** standard names to ensure maximum compatibility.

| Key | Keysym Name |
| :--- | :--- |
| `[` | `bracketleft` |
| `]` | `bracketright` |
| `=` | `equal` |
| `-` | `minus` |
| `p` | `p` (Lowercase preferred) |

### Troubleshooting Keysyms
Use `wev` (Wayland Event Viewer) to identify the exact keysym name:
```bash
nix-shell -p wev --run wev
```

## 3. Absolute Paths in Home Manager

To guarantee that commands are executed correctly regardless of the current `PATH` (especially during startup or from non-interactive shells), always use absolute paths interpolated from `pkgs`.

```nix
"Mod+Ctrl+equal".action = spawn [ "${pkgs.pamixer}/bin/pamixer" "-i" "5" ];
```

## 4. Multi-Modifier Order

While Niri is generally flexible, following the `Mod+Ctrl` or `Mod+Shift` convention is standard. Note that some users might have flipped their `Mod` key (Super/Alt) in Niri settings.

```nix
# Recommended order
"Mod+Ctrl+p".action = ...
```
