{ config, lib, pkgs, username, ... }:

{
  home-manager.users.${username} = { config, lib, ... }: {
    home.packages = with pkgs; [
          fd # Used for the search function
          dust # Modern du rewritten in Rust (beautiful overview)
          gdu # Fast interactive disk analyzer in Go (great for cleanup)
          ncdu # Classic interactive disk analyzer
          playerctl # MPRIS media player control (required for DMS media widget)
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
          ddcutil # External monitor brightness control
          brightnessctl # Brightness control utility
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
          config = {
            # --- OPTIMISATIONS GPU AMD ---
            hwdec = "auto-safe"; # Utilise le meilleur décodeur matériel disponible
            vo = "gpu-next"; # Version moderne de la sortie vidéo GPU
            gpu-context = "wayland"; # Force le contexte Wayland pour Niri
            hwdec-codecs = "all"; # Tente le décodage matériel pour tous les formats
            gpu-api = "vulkan"; # Utilise Vulkan pour de meilleures perfs sur AMD
            
            # --- ÉCONOMIE DE RAM (pour mpvpaper) ---
            cache = "no"; # Désactive le cache disque pour économiser la RAM
            demuxer-max-bytes = "50MiB"; # Limite la mémoire tampon du flux vidéo
            demuxer-max-back-bytes = "10MiB"; # Limite la mémoire tampon du flux précédent
          };
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

          # Create an M3U playlist from audio files in the CURRENT directory ONLY
          mkpl = ''
            set -l name (if test (count $argv) -gt 0; echo $argv[1]; else; echo "playlist.m3u"; end)
            # --max-depth 1: limite la recherche au répertoire courant uniquement
            ${pkgs.fd}/bin/fd --max-depth 1 -e mp3 -e flac -e m4a -e wav -e ogg . > $name
            echo "✅ Playlist created in current dir: $name"
          '';

          # Quick flake update with input name
          nfu = "nix flake update $argv";

          # Sync dynamic colors using Matugen
          upc = "matugen -c ~/nixos-config/templates/matugen.toml image \$(cat ~/.cache/noctalia/wallpapers.json | jq -r .defaultWallpaper) && makoctl reload";
        };
  };
}
