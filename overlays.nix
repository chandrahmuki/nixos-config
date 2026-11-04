{inputs, ...}: {
  nixpkgs.overlays = [
    (final: _prev: {
      pkgs-master = import inputs.nixpkgs-master {
        system = final.stdenv.hostPlatform.system;
        inherit (final) config;
      };
    })
    # nixpkgs 925d0c2 (2026-11-03): the declared hash of opencode's node_modules does not
    # match what builds (nixpkgs-master declares the same one). Drop once nixpkgs fixes it.
    (_final: prev: {
      opencode = prev.opencode.overrideAttrs (old: {
        node_modules = old.node_modules.overrideAttrs {
          outputHash = "sha256-prx9dX7kUvs/E3zopkaPk5LXh3xJAy5sZeum/W8L7cA=";
        };
      });
    })
  ];
}
