{
  config,
  lib,
  pkgs,
  inputs,
  username,
  ...
}:

let
  pkgs-master = import inputs.nixpkgs-master {
    inherit (pkgs) system;
    config = pkgs.config;
  };
in
{
  home-manager.users.${username} =
    { config, lib, ... }:
    {
      home.packages = [
        pkgs.opencode
        pkgs.opencode-claude-auth
        pkgs.gemini-cli
        pkgs.go
        pkgs-master.claude-code
        pkgs.rtk
      ];

      xdg.configHome = lib.mkDefault "${config.home.homeDirectory}/.config";

      home.file.".claude/settings.json" = {
        force = true;
        text = lib.generators.toJSON { } {
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
              env = { };
            };
            nixos = {
              command = "uvx";
              args = [ "mcp-nixos" ];
              env = { };
            };
            fetch = {
              command = "uvx";
              args = [
                "mcp-server-fetch"
                "--ignore-robots-txt"
              ];
              env = { };
            };
          };
        };
      };

      home.file."nixos-config/.gemini/settings.json".source =
        config.lib.file.mkOutOfStoreSymlink "/home/${username}/nixos-config/.agent/gemini-settings.json";
    };
}
