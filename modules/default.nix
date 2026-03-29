{ lib, ... }:

let
  # Fonction pour scanner récursivement le dossier et trouver les .nix
  # On exclut ce fichier lui-même (default.nix)
  scanModules = path:
    let
      content = builtins.readDir path;
      nixFiles = lib.filterAttrs (n: v: v == "regular" && lib.hasSuffix ".nix" n && n != "default.nix") content;
      dirs = lib.filterAttrs (n: v: v == "directory") content;
      
      # Récupération des fichiers dans le dossier actuel
      currentFiles = map (n: path + "/${n}") (builtins.attrNames nixFiles);
      
      # Récursion dans les sous-dossiers
      subDirFiles = lib.concatLists (map (n: scanModules (path + "/${n}")) (builtins.attrNames dirs));
    in
    currentFiles ++ subDirFiles;
in
{
  imports = scanModules ./.;
}
