{
  config,
  lib,
  pkgs,
  username,
  ...
}:

{
  # Activer le service système pour le backend d'applications Elephant
  services.elephant.enable = true;

  # Configurer le service systemd utilisateur d'Elephant
  systemd.user.services.elephant = {
    path = [
      pkgs.bash
      pkgs.coreutils
      pkgs.xdg-utils
      "/run/current-system/sw"
      "/etc/profiles/per-user/${username}"
      "/home/${username}/.nix-profile"
    ];
    # Retarder le démarrage pour qu'il attende que la session graphique soit active
    # et que les variables (WAYLAND_DISPLAY, DISPLAY) soient disponibles.
    wantedBy = lib.mkForce [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
  };

  # Service de fond pour démarrer Walker en mode démon et le rendre instantané
  systemd.user.services.walker = {
    description = "Walker Application Runner Daemon";
    # Chemins d'accès indispensables pour trouver l'exécutable elephant et les applications système
    path = [
      "/run/current-system/sw"
      "/etc/profiles/per-user/${username}"
      "/home/${username}/.nix-profile"
    ];
    serviceConfig = {
      # Démarrage de Walker en mode démon (GApplication-service) pour éviter les délais au chargement
      ExecStart = "${pkgs.walker}/bin/walker --gapplication-service";
      Restart = "on-failure";
    };
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
  };

  home-manager.users.${username} =
    { config, lib, ... }:
    let
      stylixColors = config.lib.stylix.colors;
    in
    {
      home.packages = [
        pkgs.walker
      ];

      # Configuration propre de Walker sans l'option 'force = true'
      xdg.configFile."walker/config.toml".text = ''
        theme = "tokyonight"
        app_launch_prefix = ""
        selection_prefix = "❯"

        [search]
        placeholder = "Search Applications..."

        [providers]
        default = [
          "desktopapplications",
          "calc",
          "websearch"
        ]
        empty = ["desktopapplications"]
        max_results = 50
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
        }

        popover {
          background: lighter(@window_bg_color);
          border: 1px solid darker(@accent_bg_color);
          border-radius: 18px;
          padding: 10px;
        }

        .normal-icons {
          -gtk-icon-size: 16px;
        }

        .large-icons {
          -gtk-icon-size: 32px;
        }

        scrollbar {
          opacity: 0;
        }

        .box-wrapper {
          box-shadow:
            0 19px 38px rgba(0, 0, 0, 0.3),
            0 15px 12px rgba(0, 0, 0, 0.22);
          background: @window_bg_color;
          padding: 20px;
          border-radius: 10px;
          border: 2px solid #${stylixColors.base0D};
        }

        .preview-box,
        .elephant-hint,
        .placeholder {
          color: @theme_fg_color;
        }

        .search-container {
          border-radius: 10px;
        }

        .input placeholder {
          opacity: 0.5;
        }

        .input selection {
          background: @accent_bg_color;
        }

        .input {
          caret-color: @theme_fg_color;
          background: @window_bg_color;
          padding: 10px;
          color: @theme_fg_color;
        }

        .list {
          color: @theme_fg_color;
        }

        .item-box {
          border-radius: 10px;
          padding: 10px;
        }

        .item-quick-activation {
          background: alpha(@accent_bg_color, 0.5);
          border-radius: 5px;
          padding: 10px;
        }

        child:selected .item-box,
        row:selected .item-box {
          background: @accent_bg_color;
        }

        .item-subtext {
          font-size: 12px;
          opacity: 0.5;
        }

        .providerlist .item-subtext {
          font-size: unset;
          opacity: 0.75;
        }

        .item-image-text {
          font-size: 28px;
        }

        .preview {
          border: 1px solid alpha(@accent_bg_color, 0.25);
          border-radius: 10px;
          color: @theme_fg_color;
        }

        .calc .item-text {
          font-size: 24px;
        }

        .symbols .item-image {
          font-size: 24px;
        }

        .todo.done .item-text-box {
          opacity: 0.25;
        }

        .todo.urgent {
          font-size: 24px;
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

        .keybinds {
          padding-top: 10px;
          border-top: 1px solid lighter(@window_bg_color);
          font-size: 12px;
          color: @theme_fg_color;
        }

        .keybind-button {
          opacity: 0.5;
        }

        .keybind-button:hover {
          opacity: 0.75;
        }

        .keybind-bind {
          text-transform: lowercase;
          opacity: 0.35;
        }

        .keybind-label {
          padding: 2px 4px;
          border-radius: 4px;
          border: 1px solid @theme_fg_color;
        }

        .color-errors {
          padding: 10px;
          background: @error_bg_color;
          color: @error_fg_color;
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
}
