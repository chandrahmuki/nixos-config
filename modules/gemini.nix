{ config, pkgs, lib, ... }:

{
  # --- GEMINI CLI (Google DeepMind AI Agent) ---
  # Cet outil permet d'utiliser la puissance de Gemini directement dans ton terminal.
  # Il peut analyser ton workspace, taider à coder et répondre à tes questions.

  home.packages = [
    pkgs.gemini-cli
    pkgs.nodejs
    pkgs.go
    pkgs.muggy
  ];

  # Utilisation de mkOutOfStoreSymlink pour lier le fichier de configuration mutable.
  # Cela permet à l'agent d'écrire son état de session sans être bloqué par le Read-Only du Nix Store.
  home.file."nixos-config/.gemini/settings.json".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-config/.agent/gemini-settings.json";

  # NOTE: GOOGLE_API_KEY est chargé dynamiquement via Fish interactiveShellInit
  # dans terminal.nix (home.sessionVariables ne supporte pas $(cat ...) avec Fish)
}
