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
        {
          plugin = power-theme;
          extraConfig = ''
            set -g @tmux_power_theme 'moon'
            set -g @tmux_power_user_icon ''
            set -g @tmux_power_session_icon '󱂬'
          '';
        }
        {
          plugin = resurrect;
          extraConfig = ''
            set -g @resurrect-strategy-nvim 'session'
            set -g @resurrect-capture-pane-contents 'on'
            set -g @resurrect-dir '~/.config/tmux/resurrect'
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

        # Détection de Neovim
        is_vim="ps -o state= -o comm= -t '#{pane_tty}' | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'"
      '';
    };
  };
}
