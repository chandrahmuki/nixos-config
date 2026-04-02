{ config, lib, pkgs, username, ... }:

let
  # Script qui setup les sessions tmux avec les commandes
  setup-tmux-sessions = pkgs.writeShellScriptBin "setup-tmux-sessions" ''
    # Start tmux server if not running
    ${pkgs.tmux}/bin/tmux start-server

    # Create main session if it doesn't exist
    if ! ${pkgs.tmux}/bin/tmux has-session -t main 2>/dev/null; then
      ${pkgs.tmux}/bin/tmux new-session -d -s main -x 200 -y 50

      # Window 1: nvim
      ${pkgs.tmux}/bin/tmux send-keys -t main "nvim" Enter

      # Window 2: claude-code
      ${pkgs.tmux}/bin/tmux new-window -t main
      ${pkgs.tmux}/bin/tmux send-keys -t main "claude-code" Enter

      # Window 3: empty (for manual work)
      ${pkgs.tmux}/bin/tmux new-window -t main

      # Select first window
      ${pkgs.tmux}/bin/tmux select-window -t main:1
    fi
  '';
in
{
  home-manager.users.${username} = { config, lib, ... }: {
    home.packages = [
      setup-tmux-sessions
    ];

    # Auto-setup tmux sessions at startup
    systemd.user.services.tmux-setup = {
      Unit = {
        Description = "Setup Tmux Sessions";
        After = [ "default.target" ];
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${setup-tmux-sessions}/bin/setup-tmux-sessions";
        RemainAfterExit = true;
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

        # Navigation fluide entre panneaux avec Alt + h/j/k/l
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
        bind -n M-s run-shell "tmux-sessionx"

        # Détection de Neovim
        is_vim="ps -o state= -o comm= -t '#{pane_tty}' | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'"
      '';
    };
  };
}
