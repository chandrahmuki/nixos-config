{inputs, ...}: {
  nixpkgs.overlays = [
    (final: prev: {
      pkgs-master = import inputs.nixpkgs-master {
        system = final.stdenv.hostPlatform.system;
        config = final.config;
      };
    })
  ];
}
