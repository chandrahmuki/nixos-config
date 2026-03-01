# Niri Notification Focus (Mako + xdg-activation)

## Problème

Cliquer sur une notification ne change pas de workspace / ne focus pas la fenêtre cible dans Niri, même en multi-écran.

**Cause racine** : SwayNC n'envoie pas de token `xdg-activation-v1` au compositeur lorsqu'un utilisateur clique sur une notification. Sans ce token, Niri ignore la demande de focus.

## Solution

### 1. Remplacer SwayNC par Mako

Mako supporte **nativement** le protocole `xdg-activation-v1` via `on-button-left = "invoke-default-action"`. Quand l'utilisateur clique, Mako envoie un token d'activation → Niri change de workspace et focus la fenêtre.

**Fichier** : `modules/notifications.nix`

```nix
services.mako = {
  enable = true;
  settings = {
    anchor = "top-right";
    on-button-left = "invoke-default-action"; # ← xdg-activation
    on-button-right = "dismiss";
    on-button-middle = "dismiss-all";
    # ...couleurs, taille, etc.
  };
  # Les critères [urgency=...] passent par extraConfig (pas settings)
  extraConfig = ''
    [urgency=critical]
    default-timeout=0
    border-color=#f38ba8
  '';
};
```

### 2. Debug flags Niri (requis)

**Fichier** : `wm/niri.nix`

```nix
debug = {
  honor-xdg-activation-with-invalid-serial = true; # Tokens imparfaits (Discord, Telegram)
  deactivate-unfocused-windows = true;              # Fix Chromium/Electron activated state
};
```

### 3. Window rule (optionnel, recommandé)

**Fichier** : `wm/style.nix`

```nix
window-rules = [{
  matches = [{ app-id = "brave-browser"; }];
  open-focused = true;
}];
```

## Points clés

| Daemon        | xdg-activation | Focus auto |
|---------------|:--------------:|:----------:|
| **Mako**      | ✅ Natif       | ✅ Oui     |
| **SwayNC**    | ❌ Non         | ❌ Non     |
| **Dunst**     | ❓ Partiel     | ❓ ?       |

## Piège Mako + Home Manager

Les **critères** Mako (`[urgency=critical]`, `[app-name=...]`) ne passent **pas** par `services.mako.settings` (erreur `Invalid criteria field`). Utiliser `extraConfig` pour les sections INI.

## Comparaison avec Hyprland

Hyprland utilise `misc:focus_on_activate = true` pour le même comportement. Niri n'a pas d'équivalent direct — il faut les debug flags + un daemon (Mako) qui envoie les tokens.
