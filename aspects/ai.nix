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
  in {
    nixpkgs.overlays = [inputs.claude-desktop.overlays.default];

    home-manager.users.${username} = {
      config,
      lib,
      ...
    }: {
      home.packages = [
        pkgs.opencode
        pkgs.opencode-claude-auth
        pkgs-master.claude-code
        pkgs.claude-desktop
        pkgs-master.codex
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
