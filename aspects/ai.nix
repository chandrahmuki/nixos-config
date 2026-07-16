{den, ...}: {
  den.aspects.ai.nixos = {
    config,
    lib,
    pkgs,
    inputs,
    username,
    ...
  }: let
    pkgs-master = import inputs.nixpkgs-master {
      system = pkgs.stdenv.hostPlatform.system;
      config = pkgs.config;
    };

    openai-codex-cli = pkgs.stdenvNoCC.mkDerivation {
      pname = "openai-codex-cli";
      version = "0.144.4";

      src = pkgs.fetchurl {
        url = "https://github.com/openai/codex/releases/download/rust-v0.144.4/codex-x86_64-unknown-linux-musl.tar.gz";
        sha256 = "1l8mfn0fr3zh459bkqhasc9c5shk2965k81s7gsc9s49knz8bj9p";
      };

      sourceRoot = ".";

      installPhase = ''
        install -m755 -D codex-x86_64-unknown-linux-musl $out/bin/codex
      '';
    };
  in {
    home-manager.users.${username} = {
      config,
      lib,
      ...
    }: {
      home.packages = [
        pkgs.opencode
        pkgs.opencode-claude-auth
        pkgs.antigravity-cli
        pkgs-master.claude-code
        openai-codex-cli
        inputs.muggy.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];

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
                "GITHUB_TOKEN=$(cat ~/.config/sops/github_token) npx -y @modelcontextprotocol/server-github"
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

  den.aspects.muggy-nixos.includes = [den.aspects.ai];
}
