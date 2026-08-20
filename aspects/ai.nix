{den, ...}: {
  den.aspects.ai.nixos = {
    config,
    lib,
    pkgs,
    inputs,
    username,
    ...
  }: let
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
        pkgs.pkgs-master.codex
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
