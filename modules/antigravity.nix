{ config, pkgs, ... }:

let
  # Extensions VSCode pour le support Nix
  nixExtensions = [
    pkgs.vscode-extensions.bbenoist.nix
    pkgs.vscode-extensions.jnoortheen.nix-ide
  ];

  # Helper pour créer les liens symboliques d'extensions dans le dossier Antigravity
  mkExtensionSymlink = ext: {
    # Format attendu par Antigravity : publisher.name-version-platform
    name = ".antigravity/extensions/${ext.vscodeExtPublisher}.${ext.vscodeExtName}-${ext.version}-universal";
    value = {
      source = "${ext}/share/vscode/extensions/${ext.vscodeExtPublisher}.${ext.vscodeExtName}";
    };
  };
in
{
  home.packages = [
    pkgs.google-antigravity
    pkgs.nil # Language Server for Nix
    pkgs.nixfmt # Formatter for Nix
  ];

  # Fichiers et configurations Antigravity
  home.file = (builtins.listToAttrs (map mkExtensionSymlink nixExtensions)) // {
    # Configuration mutable liée au dépôt git (pour permettre à l'agent d'écrire dedans si nécessaire)
    # Géré via le script d'activation plus bas pour éviter le verrouillage en lecture seule
    # ".config/Antigravity/User/settings.json".source = ...

    # Gestion persistante de la config MCP
    ".gemini/antigravity/mcp_config.json".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-config/modules/mcp_config.json";
  };

  # Activation Script : Force Brute pour le settings.json
  # Home Manager a tendance à verrouiller ce fichier en lecture seule ou à casser le lien.
  # On force ici un lien symbolique direct vers notre fichier mutable après l'activation.
  home.activation.linkAntigravitySettings = lib.hm.dag.entryAfter ["writeBoundary"] ''
    run mkdir -p $HOME/.config/Antigravity/User
    run rm -f $HOME/.config/Antigravity/User/settings.json
    run ln -sf $HOME/nixos-config/modules/antigravity-settings.json $HOME/.config/Antigravity/User/settings.json
  '';

  home.sessionVariables = {
    ANTIGRAVITY_EDITOR = "code";
  };
}
