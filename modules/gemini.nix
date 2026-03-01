{ config, pkgs, ... }:

{
  # --- GEMINI CLI (Google DeepMind AI Agent) ---
  # Cet outil permet d'utiliser la puissance de Gemini directement dans ton terminal.
  # Il peut analyser ton workspace, t'aider à coder et répondre à tes questions.

  home.packages = [
    pkgs.gemini-cli
    pkgs.nodejs
    pkgs.go
    pkgs.muggy

  ];

  # Gestion déclarative des paramètres de Gemini CLI (projet spécifique)
  home.file."Documents/P-Project/.gemini/settings.json".text = builtins.toJSON {
    # MCP_CONFIG_START
    mcpServers = {
      atlassian-mcp-server = {
        command = "npx";
        args = [
          "-y"
          "mcp-remote"
          "https://mcp.atlassian.com/v1/sse"
        ];
        env = { };
      };
      github = {
        command = "bash";
        args = [
          "-c"
          "GITHUB_PERSONAL_ACCESS_TOKEN=$(cat ${config.home.homeDirectory}/.config/antigravity/github_token) npx -y @modelcontextprotocol/server-github"
        ];
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
