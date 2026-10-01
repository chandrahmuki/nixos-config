{den, ...}: {
  den.aspects.ai.nixos = {
    config,
    lib,
    pkgs,
    inputs,
    username,
    ...
  }: let
    codexVersion = "0.159.2";
    codex = pkgs.stdenvNoCC.mkDerivation {
      pname = "codex";
      version = codexVersion;

      src = pkgs.fetchurl {
        url = "https://github.com/openai/codex/releases/download/rust-v${codexVersion}/codex-package-x86_64-unknown-linux-musl.tar.gz";
        hash = "sha256-ni0ppxO5RHiyQN7C8Q4RMkzQX6123EPnxjm9+KEzems=";
      };

      sourceRoot = ".";
      unpackPhase = "tar -xzf $src";
      installPhase = ''
        runHook preInstall
        mkdir -p $out
        cp -r bin codex-path codex-resources codex-package.json $out/
        runHook postInstall
      '';

      meta = {
        description = "Lightweight coding agent that runs in your terminal";
        homepage = "https://github.com/openai/codex";
        mainProgram = "codex";
        platforms = ["x86_64-linux"];
      };
    };

    codex-laya = pkgs.writeShellApplication {
      name = "codex-laya";
      runtimeInputs = [pkgs.uv pkgs.python313];
      text = ''
        export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath [pkgs.stdenv.cc.cc.lib pkgs.zlib]}''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"

        if [[ "''${1:-}" == "--help" || "''${1:-}" == "-h" ]]; then
          exec ${pkgs.python313}/bin/python3.13 ${../scripts/codex-laya.py} "$@"
        fi

        cache_root="''${XDG_CACHE_HOME:-$HOME/.cache}/codex-laya"
        export UV_CACHE_DIR="''${UV_CACHE_DIR:-$cache_root/uv}"
        export UV_PYTHON_INSTALL_DIR="''${UV_PYTHON_INSTALL_DIR:-$cache_root/python}"
        export HF_HOME="''${HF_HOME:-$cache_root/huggingface}"
        venv="$cache_root/venv"

        if [[ ! -x "$venv/bin/python" ]]; then
          mkdir -p "$cache_root"
          uv venv --python ${pkgs.python313}/bin/python3.13 "$venv"
        fi

        if ! "$venv/bin/python" -c 'import laya, torch' >/dev/null 2>&1; then
          uv pip install --python "$venv/bin/python" torch==2.14.0 \
            --index-url https://download.pytorch.org/whl/cpu
          uv pip install --python "$venv/bin/python" laya==0.3.20 \
            --index-url https://pypi.org/simple
        fi

        exec "$venv/bin/python" ${../scripts/codex-laya.py} "$@"
      '';
    };

    antigravity-cli = pkgs.stdenvNoCC.mkDerivation {
      pname = "antigravity-cli";
      version = "1.1.13";
      src = pkgs.fetchurl {
        url = "https://github.com/google-antigravity/antigravity-cli/releases/download/1.1.13/agy_cli_linux_x64.tar.gz";
        sha256 = "edc7c32b5ab4fc2e4da03381fee83ed566dea6b56b56f9329cd13cd77947a1d9";
      };
      sourceRoot = ".";
      nativeBuildInputs = [pkgs.autoPatchelfHook];
      buildInputs = [pkgs.stdenv.cc.cc.lib pkgs.zlib];
      installPhase = ''
        install -m755 -D antigravity $out/bin/agy
      '';
    };
  in {
    nixpkgs.overlays = [inputs.claude-desktop.overlays.default];

    home-manager.sharedModules = [inputs.omnigraph.homeManagerModules.default];

    home-manager.users.${username} = {
      config,
      lib,
      ...
    }: {
      home.packages = [
        antigravity-cli
        pkgs.opencode
        pkgs.opencode-claude-auth
        pkgs.pkgs-master.claude-code
        pkgs.claude-desktop
        codex
        codex-laya
        inputs.omnigraph.packages.${pkgs.stdenv.hostPlatform.system}.default
        inputs.muggy.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];

      programs.omnigraph.enable = true;

      xdg.configHome = lib.mkDefault "${config.home.homeDirectory}/.config";

      home.file.".claude/settings.json" = {
        text = lib.generators.toJSON {} {
          model = "sonnet";
          env = {
            MAX_THINKING_TOKENS = "8000";
          };
          mcpServers = {
            github = {
              command = "bash";
              args = [
                "-c"
                "unset GITHUB_TOKEN; exec npx -y @modelcontextprotocol/server-github"
              ];
              env = {};
            };
            nixos = {
              command = "uvx";
              args = ["mcp-nixos"];
              env = {};
            };
            fetch = {
              command = "uvx";
              args = [
                "mcp-server-fetch"
                "--ignore-robots-txt"
              ];
              env = {};
            };
          };
        };
      };
    };
  };
}
