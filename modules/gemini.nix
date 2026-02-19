{ pkgs, ... }:

{
  # --- GEMINI CLI (Google DeepMind AI Agent) ---
  # Cet outil permet d'utiliser la puissance de Gemini directement dans ton terminal.
  # Il peut analyser ton workspace, t'aider à coder et répondre à tes questions.

  home.packages = [
    pkgs.gemini-cli
  ];

  # Note : Pour utiliser cet outil, tu devras configurer ta clé API.
  # Tu peux le faire en ajoutant 'export GEMINI_API_KEY="ta_clé"' dans ton .envrc 
  # ou via un module de secrets.
}
