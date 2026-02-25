{ config, pkgs, ... }:

{
  # --- GEMINI CLI (Google DeepMind AI Agent) ---
  # Cet outil permet d'utiliser la puissance de Gemini directement dans ton terminal.
  # Il peut analyser ton workspace, t'aider à coder et répondre à tes questions.

  home.packages = [
    pkgs.gemini-cli
    pkgs.nodejs
    pkgs.chromium
  ];

  # Gestion déclarative des paramètres de Gemini CLI
  # On inclut les serveurs MCP existants et on fixe mcp-mermaid pour NixOS
  home.file."Documents/P-Project/.gemini/settings.json".text = builtins.toJSON {
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
      mcp-mermaid = {
        command = "npx";
        args = [
          "-y"
          "mcp-mermaid"
        ];
        env = {
          PLAYWRIGHT_CHROMIUM_EXECUTABLE_PATH = "${pkgs.chromium}/bin/chromium";
          PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = "1";
          CHROME_BIN = "${pkgs.chromium}/bin/chromium";
        };
      };
    };
  };

  # Note : Pour utiliser cet outil, tu devras configurer ta clé API.
  # Tu peux le faire en ajoutant 'export GEMINI_API_KEY="ta_clé"' dans ton .envrc 
  # ou via un module de secrets.
}
