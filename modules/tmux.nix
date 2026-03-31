{ config, lib, pkgs, username, ... }:

let
  # 1. Le script qui lance tmux dans foot avec la petite police
  tmux-small-script = pkgs.writeShellScriptBin "tmux-small" ''
    ${pkgs.foot}/bin/foot -f "JetBrainsMono Nerd Font:size=10" \
      ${pkgs.fish}/bin/fish -c "${pkgs.tmux}/bin/tmux attach || ${pkgs.tmux}/bin/tmux new-session"
  '';

  # 2. L'entrée desktop proprement packagée
  tmux-small-desktop = pkgs.makeDesktopItem {
    name = "tmux-small";
    desktopName = "Tmux (Small Font)";
    genericName = "Terminal Multiplexer";
    exec = "${tmux-small-script}/bin/tmux-small";
    icon = "utilities-terminal";
    categories = [ "System" "TerminalEmulator" "Development" ];
    terminal = false;
  };
in
{
  home-manager.users.${username} = { config, lib, ... }: {
    # On installe le script et l'entrée desktop
    home.packages = [ 
      tmux-small-script 
      tmux-small-desktop
    ];

    # 3. Le "Pont" : On crée un lien symbolique dans le dossier que Walker scanne forcément
    home.file.".local/share/applications/tmux-small.desktop".source = 
      "${tmux-small-desktop}/share/applications/tmux-small.desktop";

    # FIX NIXOS: Tmux server must be started automatically to allow continuum restore
    systemd.user.services.tmux = {
      Unit = {
        Description = "Tmux Server";
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${pkgs.tmux}/bin/tmux start-server";
        ExecStop = "${pkgs.tmux}/bin/tmux kill-server";
        RemainAfterExit = true;
        Restart = "on-failure";
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };

    programs.tmux = {
      enable = true;
      shortcut = "b";
      baseIndex = 1;
      newSession = true;
      escapeTime = 0;
      mouse = true;
      keyMode = "vi";
      terminal = "tmux-256color";
      historyLimit = 10000;

      plugins = with pkgs.tmuxPlugins; [
        sensible
        yank
        tokyo-night-tmux
        tmux-sessionx
        tmux-fzf
        {
          plugin = resurrect;
          extraConfig = ''
            set -g @resurrect-strategy-nvim 'session'
            set -g @resurrect-capture-pane-contents 'on'
            set -g @resurrect-dir '~/.local/share/tmux/resurrect'
            set -g @resurrect-hook-post-save-all 'echo "Saved!"'
          '';
        }
        {
          plugin = continuum;
          extraConfig = ''
            set -g @continuum-restore 'on'
            set -g @continuum-save-interval '5'
          '';
        }
        vim-tmux-navigator
      ];

      extraConfig = ''
        # Theme Tokyo Night
        set -g @tokyo-night-tmux_theme moon
        set -g @tokyo-night-tmux_window_id_style digital
        set -g @tokyo-night-tmux_pane_id_style icon
        set -g @tokyo-night-tmux_zoom_id_style icon
        set -g @tokyo-night-tmux_show_datetime 0
        set -g @tokyo-night-tmux_show_path 1
        set -g @tokyo-night-tmux_path_format relative
        set -g @tokyo-night-tmux_show_battery_widget 0
        set -g @tokyo-night-tmux_show_git 1

        set -g status-position top
        set -s exit-empty off

        # Navigation fluide entre panneaux avec Alt + h/j/k/l (comme Zellij)
        bind-key -n M-h if-shell "$is_vim" "send-keys M-h"  "select-pane -L"
        bind-key -n M-j if-shell "$is_vim" "send-keys M-j"  "select-pane -D"
        bind-key -n M-k if-shell "$is_vim" "send-keys M-k"  "select-pane -U"
        bind-key -n M-l if-shell "$is_vim" "send-keys M-l"  "select-pane -R"

        # Splits plus intuitifs
        bind s split-window -v -c "#{pane_current_path}"
        bind v split-window -h -c "#{pane_current_path}"

        # Rechargement rapide
        bind r source-file ~/.config/tmux/tmux.conf \; display "Config reloaded!"

        # Navigation rapide par onglets (Tabs) avec Alt
        bind -n M-1 select-window -t 1
        bind -n M-2 select-window -t 2
        bind -n M-3 select-window -t 3
        bind -n M-4 select-window -t 4
        bind -n M-5 select-window -t 5
        bind -n M-6 select-window -t 6
        bind -n M-7 select-window -t 7
        bind -n M-8 select-window -t 8
        bind -n M-9 select-window -t 9

        # Gestion des onglets
        bind -n M-n new-window -c "#{pane_current_path}"
        bind -n M-w kill-window
        bind -n M-Left previous-window
        bind -n M-Right next-window

        # SessionX : Fuzzy Finder Alt + s
        set -g @sessionx-bind 's'
        # On bind aussi sur Alt+s directement via tmux
        bind -n M-s run-shell "tmux-sessionx" 

        # Détection de Neovim
        is_vim="ps -o state= -o comm= -t '#{pane_tty}' | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'"
      '';
    };
  };
}
