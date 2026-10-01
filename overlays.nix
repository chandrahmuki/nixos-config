{inputs, ...}: {
  nixpkgs.overlays = [
    (final: _prev: {
      pkgs-master = import inputs.nixpkgs-master {
        system = final.stdenv.hostPlatform.system;
        inherit (final) config;
      };
    })
  ];
}
