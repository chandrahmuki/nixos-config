{ config, pkgs, ... }:

{
  # --- GEMINI CLI (Google DeepMind AI Agent) ---
  # Cet outil permet d'utiliser la puissance de Gemini directement dans ton terminal.
  # Il peut analyser ton workspace, t'aider à coder et répondre à tes questions.

  home.packages = [
    pkgs.gemini-cli
    
    # Wrapper for skillfish (AI agent skill manager)
    (pkgs.writeShellScriptBin "skillfish" ''
      exec npx -y skillfish "$@"
    '')
  ];

  # Gestion déclarative des paramètres de Gemini CLI
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
    };
  };

  # Note : Pour utiliser cet outil, tu devras configurer ta clé API.
  # Tu peux le faire en ajoutant 'export GEMINI_API_KEY="ta_clé"' dans ton .envrc 
  # ou via un module de secrets.
}
