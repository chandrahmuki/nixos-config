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
    nodejs # For MCP servers and other node-based tools
    rich-cli # Beautiful terminal renderer for Markdown (hides # markers)
    python3 # For advanced tools like the Kira scratchpad script
    repomix # Pack repository contents to single file for AI consumption
    qpdf # For decrypting PDFs
    jq # For parsing JSON (useful for flake.lock)
    matugen # Material You color generation tool
    uv # Extremely fast Python package manager (provides uvx)
    cava # Console-based Audio Visualizer for Alsa/PulseAudio/PipeWire
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
    # Quick markdown preview with rich-cli
    md = "rich --markdown $argv";

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

    # Audio-only playback with mpv
    mpno = "mpv --no-video $argv";

    # Create an M3U playlist from audio files in the current directory and subdirectories
    mkpl = ''
      set -l name (if test (count $argv) -gt 0; echo $argv[1]; else; echo "playlist.m3u"; end)
      ${pkgs.fd}/bin/fd -e mp3 -e flac -e m4a -e wav -e ogg . > $name
      echo "✅ Playlist created: $name"
    '';

    # Quick flake update with input name
    nfu = "nix flake update $argv";

    # Sync dynamic colors using Matugen
    upc = "matugen -c ~/nixos-config/templates/matugen.toml image \$(cat ~/.cache/noctalia/wallpapers.json | jq -r .defaultWallpaper) && makoctl reload";
  };
}
