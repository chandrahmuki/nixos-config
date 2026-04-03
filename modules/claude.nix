{ config, lib, pkgs, username, ... }:

{
  home-manager.users.${username} = { config, lib, ... }: {
    home.packages = [
      pkgs.claude-code
    ];

    # Claude Code MCP Configuration
    xdg.configHome = lib.mkDefault "${config.home.homeDirectory}/.config";
    home.file.".claude/settings.json".text = lib.generators.toJSON {} {
      model = "sonnet";
      env = {
        MAX_THINKING_TOKENS = "8000";
      };
      mcpServers = {
        github = {
          command = "bash";
          args = [
            "-c"
            "GITHUB_TOKEN=$(cat ~/.config/antigravity/github_token) npx -y @modelcontextprotocol/server-github"
          ];
          env = {};
        };
        nixos = {
          command = "uvx";
          args = [ "mcp-nixos" ];
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
}
