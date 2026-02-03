{ pkgs, ... }:

{
  home.packages = with pkgs; [
    fd # Used for the search function
    playerctl # MPRIS media player control (required for DMS media widget)
    nvd # Differenz between builds (shows package changes)
    manix # Fast Nix documentation searcher
    pamixer # CLI mixer for PulseAudio/PipeWire (volume control)
    pavucontrol # GUI volume control for PulseAudio/PipeWire
    pulseaudio # Provides pactl for volume control
  ];

  programs.bat = {
    enable = true;
    config = {
      theme = "Dracula";
    };
  };

  programs.mpv = {
    enable = true;
    scripts = with pkgs.mpvScripts; [
      mpris # MPRIS support for media player detection (DMS, playerctl)
    ];
  };

  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.fish.functions = {
    # Search function that searches from root (/)
    # Uses fd for speed, searching globally
    search = ''
      if test (count $argv) -eq 0
        echo "Usage: search <query>"
        return 1
      end

      # Launch fzf in interactive mode
      # --disabled: Do not let fzf filter the results, let fd handle it via reload
      # --query: Pre-fill with the user's argument
      # --bind: Reload fd whenever the query string changes
      # --preview: Optional but nice, shows file content with bat
      ${pkgs.fzf}/bin/fzf --disabled --query "$argv" \
        --bind "start:reload:${pkgs.fd}/bin/fd {q} / 2>/dev/null" \
        --bind "change:reload:${pkgs.fd}/bin/fd {q} / 2>/dev/null" \
        --preview "${pkgs.bat}/bin/bat --color=always --style=numbers --line-range=:500 {}"
    '';

    # Alternative if they want to fzf the results:
    # search_interactive = "fd . / 2>/dev/null | fzf";
  };
}
