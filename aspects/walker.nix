{den, ...}: {
  den.aspects.walker.nixos = {
    config,
    lib,
    pkgs,
    username,
    ...
  }: {
    # Activer le service système pour le backend d'applications Elephant
    services.elephant.enable = true;

    # Configurer le service systemd utilisateur d'Elephant
    systemd.user.services.elephant = {
      path = [
        "/run/wrappers/bin"
        "/run/current-system/sw/bin"
        "/etc/profiles/per-user/${username}/bin"
        "/home/${username}/.nix-profile/bin"
        pkgs.bash
        pkgs.coreutils
        pkgs.xdg-utils
      ];
      # Retarder le démarrage pour qu'il attende que la session graphique soit active
      # et que les variables (WAYLAND_DISPLAY, DISPLAY) soient disponibles.
      wantedBy = lib.mkForce ["graphical-session.target"];
      partOf = ["graphical-session.target"];
    };

    # Service de fond pour démarrer Walker en mode démon et le rendre instantané
    systemd.user.services.walker = {
      description = "Walker Application Runner Daemon";
      # Chemins d'accès indispensables pour trouver l'exécutable elephant et les applications système
      path = [
        "/run/wrappers/bin"
        "/run/current-system/sw/bin"
        "/etc/profiles/per-user/${username}/bin"
        "/home/${username}/.nix-profile/bin"
      ];
      serviceConfig = {
        # Démarrage de Walker en mode démon (GApplication-service) pour éviter les délais au chargement
        ExecStart = "${pkgs.walker}/bin/walker --gapplication-service";
        Restart = "on-failure";
      };
      wantedBy = ["graphical-session.target"];
      partOf = ["graphical-session.target"];
    };

    home-manager.users.${username} = {
      config,
      lib,
      ...
    }: let
      stylixColors = config.lib.stylix.colors;
    in {
      home.packages = [
        pkgs.walker
      ];

      # Configuration de Walker style Omarchy (sans 'force = true')
      xdg.configFile."walker/config.toml".text = ''
        theme = "tokyonight"
        app_launch_prefix = ""
        selection_prefix = ""

        [search]
        placeholder = "Search Applications, Commands, Calculations..."

        [providers]
        default = [
          "desktopapplications",
          "calc",
          "websearch"
        ]
        empty = ["desktopapplications"]
        max_results = 40

        [providers.calc]
        prefix = "="

        [providers.websearch]
        prefix = "?"
      '';

      xdg.configFile."walker/themes/tokyonight/style.css".text = ''
        @define-color window_bg_color #${stylixColors.base00};
        @define-color accent_bg_color #${stylixColors.base02};
        @define-color theme_fg_color #${stylixColors.base05};
        @define-color error_bg_color #${stylixColors.base08};
        @define-color error_fg_color #${stylixColors.base05};
        @define-color match_color #${stylixColors.base0D};

        * {
          all: unset;
          font-family: "JetBrainsMono Nerd Font", monospace;
        }

        popover {
          background: alpha(@window_bg_color, 0.95);
          border: 1px solid alpha(@match_color, 0.3);
          border-radius: 16px;
          padding: 12px;
          box-shadow: 0 20px 40px rgba(0, 0, 0, 0.4);
        }

        .normal-icons {
          -gtk-icon-size: 24px;
        }

        .large-icons {
          -gtk-icon-size: 36px;
        }

        scrollbar {
          opacity: 0;
        }

        /* Conteneur principal (Fenêtre style Omarchy Glassmorphism) */
        .box-wrapper {
          box-shadow:
            0 24px 48px -12px rgba(0, 0, 0, 0.6),
            0 0 1px 1px alpha(@match_color, 0.25);
          background: alpha(@window_bg_color, 0.92);
          backdrop-filter: blur(24px);
          -gtk-backdrop-filter: blur(24px);
          padding: 18px 20px;
          border-radius: 16px;
          border: 1px solid alpha(@match_color, 0.35);
        }

        .preview-box,
        .elephant-hint,
        .placeholder {
          color: @theme_fg_color;
        }

        /* Barre de recherche style capsule */
        .search-container {
          background: alpha(@accent_bg_color, 0.45);
          border: 1px solid alpha(@theme_fg_color, 0.1);
          border-radius: 12px;
          margin-bottom: 12px;
          padding: 2px 6px;
        }

        .input placeholder {
          color: alpha(@theme_fg_color, 0.45);
          font-style: normal;
        }

        .input selection {
          background: alpha(@accent_bg_color, 0.8);
        }

        .input {
          caret-color: @match_color;
          padding: 12px 14px;
          color: @theme_fg_color;
          font-size: 15px;
          font-weight: 500;
        }

        /* Liste des résultats */
        .list {
          color: @theme_fg_color;
        }

        .item-box {
          border-radius: 10px;
          padding: 10px 14px;
          margin: 3px 0px;
        }

        .item-quick-activation {
          background: alpha(@window_bg_color, 0.8);
          border: 1px solid alpha(@theme_fg_color, 0.15);
          border-radius: 6px;
          padding: 4px 8px;
          font-size: 11px;
          font-weight: bold;
          color: @match_color;
        }

        /* Élément sélectionné (effet pilule Omarchy) */
        child:selected .item-box,
        row:selected .item-box {
          background: alpha(@accent_bg_color, 0.7);
          border: 1px solid alpha(@match_color, 0.4);
        }

        .item-text {
          font-size: 14px;
          font-weight: 600;
          color: @theme_fg_color;
        }

        .item-subtext {
          font-size: 12px;
          opacity: 0.6;
          color: @theme_fg_color;
          margin-top: 2px;
        }

        .providerlist .item-subtext {
          font-size: 12px;
          opacity: 0.75;
        }

        .item-image-text {
          font-size: 28px;
        }

        .preview {
          border: 1px solid alpha(@match_color, 0.2);
          background: alpha(@accent_bg_color, 0.25);
          border-radius: 12px;
          padding: 14px;
          color: @theme_fg_color;
        }

        .calc .item-text {
          font-size: 22px;
          font-weight: 600;
          color: @match_color;
        }

        .symbols .item-image {
          font-size: 24px;
        }

        .todo.done .item-text-box {
          opacity: 0.3;
        }

        .todo.urgent {
          font-size: 20px;
          color: @error_bg_color;
        }

        .todo.active {
          font-weight: bold;
        }

        .bluetooth.disconnected {
          opacity: 0.5;
        }

        .preview .large-icons {
          -gtk-icon-size: 64px;
        }

        /* Pied de page & Raccourcis */
        .keybinds {
          padding-top: 12px;
          margin-top: 10px;
          border-top: 1px solid alpha(@theme_fg_color, 0.08);
          font-size: 12px;
          color: alpha(@theme_fg_color, 0.6);
        }

        .keybind-button {
          opacity: 0.7;
        }

        .keybind-button:hover {
          opacity: 1;
        }

        .keybind-bind {
          text-transform: uppercase;
          font-size: 10px;
          opacity: 0.5;
        }

        .keybind-label {
          padding: 3px 6px;
          border-radius: 5px;
          background: alpha(@accent_bg_color, 0.5);
          border: 1px solid alpha(@theme_fg_color, 0.12);
          color: @theme_fg_color;
          font-weight: 600;
          font-size: 11px;
        }

        .color-errors {
          padding: 10px;
          background: @error_bg_color;
          color: @error_fg_color;
          border-radius: 8px;
        }

        :not(.calc).current {
          font-style: italic;
        }

        .preview-content.archlinuxpkgs,
        .preview-content.dnfpackages {
          font-family: monospace;
        }

        label.match {
          color: @match_color;
          font-weight: bold;
        }
      '';
    };
  };

}
