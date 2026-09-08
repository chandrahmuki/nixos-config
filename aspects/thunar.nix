{den, ...}: {
  den.aspects.thunar.nixos = {pkgs, ...}: {
    services = {
      gvfs.enable = true;
      tumbler.enable = true;
    };
    environment.systemPackages = with pkgs; [
      thunar
      thunar-archive-plugin
      file-roller
      p7zip
      unrar
    ];
  };

}
