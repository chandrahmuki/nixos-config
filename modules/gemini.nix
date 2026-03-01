{ config, pkgs, ... }:

{
  # --- GEMINI CLI (Google DeepMind AI Agent) ---
  # Cet outil permet dutiliser la puissance de Gemini directement dans ton terminal.
  # Il peut analyser ton workspace, taider à coder et répondre à tes questions.

  home.packages = [
    pkgs.gemini-cli
    pkgs.nodejs
    pkgs.go
    pkgs.muggy
  ];

  # Gestion déclarative des paramètres de Gemini CLI (projet spécifique)
  # Le fichier est placé dans .gemini/settings.json à la racine du dépôt pour être chargé par lagent
  home.file."nixos-config/.gemini/settings.json".text = builtins.toJSON {
    # GSD_CONFIG_START
    commands.directories = [ ".gemini/commands" ];
    agents.directories = [ ".gemini/agents" ];
    skills = {
      enabled = true;
      directories = [ ".gemini/skills" ];
    };
    knowledge.directories = [ ".gemini/knowledge" ];
    workflows.directories = [ ".gemini/workflows" ];
    hooks = {
      BeforeTool = [
        {
          matcher = ".*";
          hooks = [
            {
              type = "command";
              command = "node .gemini/hooks/gsd-statusline.js";
            }
            {
              type = "command";
              command = "node .gemini/hooks/gsd-context-monitor.js";
            }
            {
              type = "command";
              command = "node .gemini/hooks/gsd-check-update.js";
            }
          ];
        }
      ];
    };
    # GSD_CONFIG_END

    # MCP_CONFIG_START
    mcpServers = {
      github = {
        command = "bash";
        args = [
          "-c"
          "GITHUB_PERSONAL_ACCESS_TOKEN=$(cat ${config.home.homeDirectory}/.config/antigravity/github_token) npx -y @modelcontextprotocol/server-github"
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
        args = [ "mcp-server-fetch" "--ignore-robots-txt" ];
        env = { };
      };
      sequential-thinking = {
        command = "npx";
        args = [ "-y" "@modelcontextprotocol/server-sequential-thinking" ];
        env = { };
      };
      html-to-markdown-mcp = {
        command = "npx";
        args = [ "-y" "html-to-markdown-mcp" ];
        env = { };
      };
    };
    # MCP_CONFIG_END
  };

  # NOTE: GOOGLE_API_KEY est chargé dynamiquement via Fish interactiveShellInit
  # dans terminal.nix (home.sessionVariables ne supporte pas $(cat ...) avec Fish)
}
