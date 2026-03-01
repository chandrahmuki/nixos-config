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

  # Activation Script : Force Brute pour le settings.json (Mutable)
  # On force ici un lien symbolique vers notre fichier mutable après l'activation.
  # Cela permet à l'agent d'écrire son état de session sans être bloqué par le Read-Only de Nix.
  home.activation.linkGeminiSettings = lib.hm.dag.entryAfter ["writeBoundary"] ''
    run mkdir -p $HOME/nixos-config/.gemini
    run rm -f $HOME/nixos-config/.gemini/settings.json
    run ln -sf $HOME/nixos-config/.agent/gemini-settings.json $HOME/nixos-config/.gemini/settings.json
  '';

  # NOTE: GOOGLE_API_KEY est chargé dynamiquement via Fish interactiveShellInit
  # dans terminal.nix (home.sessionVariables ne supporte pas $(cat ...) avec Fish)
}
