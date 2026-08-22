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
        pkgs.elephant
        pkgs.walker
        pkgs.bash
        pkgs.coreutils
        pkgs.xdg-utils
        "/run/wrappers"
        "/run/current-system/sw"
        "/etc/profiles/per-user/${username}"
        "/home/${username}/.nix-profile"
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
        pkgs.elephant
        pkgs.walker
        pkgs.bash
        pkgs.coreutils
        pkgs.xdg-utils
        "/run/wrappers"
        "/run/current-system/sw"
        "/etc/profiles/per-user/${username}"
        "/home/${username}/.nix-profile"
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

      # Copie du layout.xml par défaut de Walker (package version 2.17.0,
      # resources/themes/default/layout.xml) avec juste width-request et
      # max/min-content-width réduits (600→480, 500→400). Reste de la
      # structure identique à l'original pour éviter de réintroduire le bug
      # d'ellipse Pango rencontré avec une largeur trop étroite (300px).
      xdg.configFile."walker/themes/tokyonight/layout.xml".text = ''
        <?xml version="1.0" encoding="UTF-8"?>
        <interface>
          <requires lib="gtk" version="4.0"></requires>
          <object class="GtkWindow" id="Window">
            <style>
              <class name="window"></class>
            </style>
            <property name="resizable">true</property>
            <property name="title">Walker</property>
            <child>
              <object class="GtkBox" id="BoxWrapper">
                <style>
                  <class name="box-wrapper"></class>
                </style>
                <property name="overflow">hidden</property>
                <property name="orientation">horizontal</property>
                <property name="valign">center</property>
                <property name="halign">center</property>
                <property name="width-request">480</property>
                <property name="height-request">570</property>
                <child>
                  <object class="GtkBox" id="Box">
                    <style>
                      <class name="box"></class>
                    </style>
                    <property name="orientation">vertical</property>
                    <property name="hexpand-set">true</property>
                    <property name="hexpand">true</property>
                    <property name="spacing">10</property>
                    <child>
                      <object class="GtkBox" id="SearchContainer">
                        <style>
                          <class name="search-container"></class>
                        </style>
                        <property name="overflow">hidden</property>
                        <property name="orientation">horizontal</property>
                        <property name="halign">fill</property>
                        <property name="hexpand-set">true</property>
                        <property name="hexpand">true</property>
                        <child>
                          <object class="GtkEntry" id="Input">
                            <style>
                              <class name="input"></class>
                            </style>
                            <property name="halign">fill</property>
                            <property name="hexpand-set">true</property>
                            <property name="hexpand">true</property>
                          </object>
                        </child>
                      </object>
                    </child>
                    <child>
                      <object class="GtkBox" id="ContentContainer">
                        <style>
                          <class name="content-container"></class>
                        </style>
                        <property name="orientation">horizontal</property>
                        <property name="spacing">10</property>
                        <child>
                          <object class="GtkLabel" id="ElephantHint">
                            <style>
                              <class name="elephant-hint"></class>
                            </style>
                            <property name="label">Waiting for elephant...</property>
                            <property name="hexpand">true</property>
                            <property name="vexpand">true</property>
                            <property name="visible">false</property>
                            <property name="valign">0.5</property>
                          </object>
                        </child>
                        <child>
                          <object class="GtkLabel" id="Placeholder">
                            <style>
                              <class name="placeholder"></class>
                            </style>
                            <property name="label">No Results</property>
                            <property name="hexpand">true</property>
                            <property name="vexpand">true</property>
                            <property name="valign">0.5</property>
                          </object>
                        </child>
                        <child>
                          <object class="GtkScrolledWindow" id="Scroll">
                            <style>
                              <class name="scroll"></class>
                            </style>
                            <property name="can_focus">false</property>
                            <property name="overlay-scrolling">true</property>
                            <property name="hexpand">true</property>
                            <property name="vexpand">true</property>
                            <property name="max-content-width">400</property>
                            <property name="min-content-width">400</property>
                            <property name="max-content-height">400</property>
                            <property name="propagate-natural-height">true</property>
                            <property name="propagate-natural-width">true</property>
                            <property name="hscrollbar-policy">automatic</property>
                            <property name="vscrollbar-policy">automatic</property>
                            <child>
                              <object class="GtkGridView" id="List">
                                <style>
                                  <class name="list"></class>
                                </style>
                                <property name="max_columns">1</property>
                                <property name="min_columns">1</property>
                                <property name="can_focus">false</property>
                              </object>
                            </child>
                          </object>
                        </child>
                        <child>
                          <object class="GtkBox" id="Preview">
                            <style>
                              <class name="preview"></class>
                            </style>
                          </object>
                        </child>
                      </object>
                    </child>
                    <child>
                      <object class="GtkBox" id="Keybinds">
                        <property name="visible">false</property>
                        <child>
                          <object class="GtkBox" id="GlobalKeybinds" />
                        </child>
                        <child>
                          <object class="GtkBox" id="ItemKeybinds" />
                        </child>
                      </object>
                    </child>
                    <child>
                      <object class="GtkLabel" id="Error">
                        <style>
                          <class name="error"></class>
                        </style>
                        <property name="xalign">0</property>
                        <property name="visible">false</property>
                      </object>
                    </child>
                  </object>
                </child>
              </object>
            </child>
          </object>
        </interface>
      '';

      # Walker tourne en démon (--gapplication-service) et ne relit jamais son
      # thème/layout après démarrage : sans ce hook, tout changement de CSS/
      # config.toml reste invisible tant qu'on ne relance pas le service à la
      # main. On le redémarre donc à chaque switch pour que "nos" suffise.
      home.activation.restartWalker = lib.hm.dag.entryAfter ["reloadSystemd"] ''
        $DRY_RUN_CMD ${pkgs.systemd}/bin/systemctl --user restart walker.service elephant.service 2>/dev/null || true
      '';

      # Configuration de Walker style Omarchy (sans 'force = true')
      xdg.configFile."walker/config.toml".text = ''
        theme = "tokyonight"
        app_launch_prefix = ""
        selection_prefix = ""
        hide_quick_activation = true
        hide_action_hints = true

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
          background: alpha(@window_bg_color, 0.94);
          padding: 18px 20px;
          border-radius: 16px;
          border: 1px solid alpha(@match_color, 0.35);
        }

        .preview-box,
        .elephant-hint,
        .placeholder {
          color: @theme_fg_color;
        }

        /* Barre de recherche : simple, pas de capsule */
        .search-container {
          background: transparent;
          border: none;
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

        /* hide_quick_activation=true dans config.toml devrait déjà les
           retirer, on les écrase aussi en CSS au cas où (F1/F2/F3...). */
        .item-quick-activation {
          font-size: 0px;
          min-width: 0px;
          opacity: 0;
          margin: 0;
          padding: 0;
        }

        /* Élément sélectionné : highlight léger, juste le texte qui change de couleur */
        child:selected .item-box,
        row:selected .item-box {
          background: alpha(@accent_bg_color, 0.25);
        }

        child:selected .item-text,
        row:selected .item-text {
          color: @match_color;
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
