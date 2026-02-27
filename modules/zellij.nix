{ pkgs, ... }:

let
  zjstatus = pkgs.fetchurl {
    url = "https://github.com/dj95/zjstatus/releases/download/v0.22.0/zjstatus.wasm";
    sha256 = "0lyxah0pzgw57wbrvfz2y0bjrna9bgmsw9z9f898dgqw1g92dr2d";
  };
in
{
  programs.zellij = {
    enable = true;
    enableFishIntegration = true; # David utilise fish
    
    settings = {
      pane_frames = false;
      theme = "tokyonight-moon"; # On reste sur le thème de David
      default_layout = "compact"; # Layout minimaliste par défaut
      mouse_mode = true;
      copy_on_select = true;
      
      # Configuration pour Neovim : On utilise le mode "locked" pour laisser Nvim gérer ses raccourcis
      # On peut aussi désactiver les raccourcis conflictuels ici si nécessaire.
    };

    # Layout personnalisé avec zjstatus
    layouts = {
      default = ''
        layout {
            default_tab_template {
                children
                pane size=1 borderless=true {
                    plugin location="file:${zjstatus}" {
                        // Configuration zjstatus
                        format_left  "{mode}#[fg=#89b4fa,bold] {session} {tabs}"
                        format_right "{command_git_branch}#[fg=#424242,bold] | {datetime}"
                        format_space ""

                        border_enabled  "false"
                        border_char     "─"
                        border_format   "#[fg=#6C7086]{char}"
                        border_position "top"

                        hide_frame_for_single_pane "true"

                        mode_normal  "#[bg=#89b4fa,fg=#181825,bold] NORMAL "
                        mode_locked  "#[bg=#f38ba8,fg=#181825,bold] LOCKED "
                        mode_tmux    "#[bg=#ff9e64,fg=#181825,bold] TMUX "

                        tab_normal   "#[fg=#6C7086] {name} "
                        tab_active   "#[fg=#89b4fa,bold,italic] {name} "

                        command_git_branch_command     "git rev-parse --abbrev-ref HEAD"
                        command_git_branch_format      "#[fg=blue] {stdout} "
                        command_git_branch_interval    "10"
                        command_git_branch_rendermode  "static"

                        datetime        "#[fg=#6C7086,bold] {format} "
                        datetime_format "%A, %d %b %Y %H:%M"
                        datetime_timezone "Europe/Paris"
                    }
                }
            }
        }
      '';
    };
  };
}
