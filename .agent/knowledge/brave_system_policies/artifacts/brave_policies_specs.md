# 🌐 Brave Configuration (Policies & UI)

## Contexte
Sur NixOS, la gestion de Brave se divise en deux parties : les politiques système (via Chromium) pour le forçage d'extensions/PWAs, et la configuration utilisateur (Home-Manager) pour l'interface et les flags d'exécution.

## Implémentation

### Politiques Système (Extensions, PWAs & Thèmes)
Le module `modules/brave-system.nix` utilise les options Chromium :
```nix
programs.chromium.extraOpts = {
  "ExtensionInstallForcelist" = [
    # Thème : Thassos Sea View
    "dcbfghmdnnkkkjjpmghnoaidojfickmj;https://clients2.google.com/service/update2/crx"
    # Bitwarden, uBlock, etc.
  ];
  "WebAppInstallForceList" = [
    {
      url = "https://teams.microsoft.com/";
      default_launch_container = "window";
      create_desktop_shortcut = true;
    }
  ];
};
```

### Configuration Visuelle (Dark Mode & Wayland)
Le module `modules/brave.nix` (Home-Manager) configure les flags pour un support natif de Wayland et un mode sombre forcé :
```nix
programs.brave.commandLineArgs = [
  "--unlimited-storage"
  "--ozone-platform=wayland"           # Force l'utilisation native de Wayland
  "--force-dark-mode"                  # Force le mode sombre pour l'UI
  "--enable-features=UseOzonePlatform,WebContentsForceDark" # Force le mode sombre pour le contenu web
];
```

## Avantages
- **Persistance** : Les extensions, thèmes et PWAs sont installés dès le premier lancement.
- **Support Wayland** : Meilleure performance et intégration dans les environnements comme Niri.
- **Uniformité Visuelle** : Dark mode forcé partout (UI + contenu) avec un thème premium appliqué.

## Fichiers clés
- `modules/brave-system.nix` : Gère le forçage système (extensions, PWAs, thème).
- `modules/brave.nix` : Gère les flags utilisateur, le mode sombre et l'interface.

## Maintenance
- **Flags** : Pour modifier le comportement graphique, éditer `commandLineArgs` dans `modules/brave.nix`.
- **Extensions/Thèmes** : Ajouter l'ID dans `ExtensionInstallForcelist` (`brave-system.nix`).
- **PWAs** : Ajouter l'URL et les options dans `WebAppInstallForceList`.
