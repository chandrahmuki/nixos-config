{den, ...}: {
  den.aspects.media.nixos = {
    config,
    lib,
    pkgs,
    username,
    ...
  }: {
    home-manager.users.${username} = {
      config,
      lib,
      ...
    }: let
      # Same album artist on every track of a downloaded album (files/music/album-artist.sh).
      albumArtist = pkgs.writeShellScript "album-artist" (builtins.replaceStrings ["@ffmpeg@" "@ffprobe@" "@jq@"] ["${pkgs.ffmpeg}/bin/ffmpeg" "${pkgs.ffmpeg}/bin/ffprobe" "${pkgs.jq}/bin/jq"] (builtins.readFile ../files/music/album-artist.sh));
      syncCliampPlaylists = pkgs.writeShellScriptBin "sync-cliamp-playlists" ''
                playlists_dir="$HOME/.config/cliamp/playlists"
                mkdir -p "$playlists_dir"

                if [ -d "$HOME/Music/Likes" ]; then
                  find "$HOME/Music/Likes" -type f -name "*.m3u" | while read -r m3u_file; do
                    playlist_name=$(basename "$m3u_file" .m3u | tr '[:upper:]' '[:lower:]' | tr ' ' '_')
                    toml_file="$playlists_dir/$playlist_name.toml"
                    : > "$toml_file"
                    m3u_dir=$(dirname "$m3u_file")

                    while IFS= read -r line || [ -n "$line" ]; do
                      [[ "$line" =~ ^[[:space:]]*$ || "$line" =~ ^# ]] && continue
                      if [[ "$line" = /* ]]; then audio_path="$line"; else audio_path="$m3u_dir/$line"; fi
                      if [ -f "$audio_path" ]; then
                        filename=$(basename "$audio_path")
                        title="''${filename%.*}"
                        title="''${title//_/ }"
                        cat >> "$toml_file" <<EOF
        [[track]]
        path = "$audio_path"
        title = "$title"

        EOF
                      fi
                    done < "$m3u_file"
                  done
                fi
      '';
    in {
      programs.mpv = {
        enable = true;
        scripts = with pkgs.mpvScripts; [
          mpris
        ];
        config = {
          hwdec = "auto-safe";
          vo = "gpu-next";
          gpu-context = "wayland";
        };
      };

      programs.yt-dlp = {
        enable = true;
        settings = {
          embed-thumbnail = true;
          add-metadata = true;
          restrict-filenames = true;
          windows-filenames = true;
          output = "%(title)s.%(ext)s";
          extractor-args = "youtube:player_client=web_embedded,web";
          cookies-from-browser = "chromium:${config.home.homeDirectory}/.config/net.imput.helium/Default";
        };
      };

      home.packages = [
        pkgs.cliamp
        syncCliampPlaylists
      ];

      xdg.configFile."cliamp/radios.toml".source = ../assets/cliamp-radios.toml;

      home.activation.createCliampPlaylistsDir = config.lib.dag.entryAfter ["writeBoundary"] ''
        $DRY_RUN_CMD mkdir -p ${config.home.homeDirectory}/.config/cliamp/playlists
        $DRY_RUN_CMD ${syncCliampPlaylists}/bin/sync-cliamp-playlists 2>/dev/null || true
      '';

      programs.fish.functions = {
        # Take the native m4a stream (AAC) when YouTube has one: the default "bestaudio" picks
        # Opus and then re-encodes it to AAC, a second lossy pass for no gain.
        yt = ''
          set -l list (mktemp)
          yt-dlp -f 'bestaudio[ext=m4a]/bestaudio' -x --audio-format m4a --print-to-file after_move:filepath $list $argv
          ${albumArtist} $list
          rm -f $list
        '';

        mpno = ''
          set -l SOCKET /tmp/mpv-music.sock
          set -l FILE $argv[1]
          if test -S $SOCKET
              echo "{\"command\": [\"loadfile\", \"$FILE\"]}" | ${pkgs.socat}/bin/socat - $SOCKET
          else
              mpv --no-video --ao=pipewire --vo=null --hwdec=no --input-ipc-server=$SOCKET "$FILE" &
              disown
          end
          ${pkgs.libnotify}/bin/notify-send -t 2000 "🎵 Musique" (basename "$FILE")
        '';

        mkpl = ''
          set -l name (if test (count $argv) -gt 0; echo $argv[1]; else; echo "playlist.m3u"; end)
          ${pkgs.fd}/bin/fd --max-depth 1 -e mp3 -e flac -e m4a -e wav -e ogg . > $name
          echo "✅ Playlist created in current dir: $name"
        '';
      };
    };
  };
}
