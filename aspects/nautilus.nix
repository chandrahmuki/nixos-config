{den, ...}: {
  den.aspects.nautilus.nixos = {pkgs, ...}: {
    services = {
      gvfs.enable = true;
      tumbler.enable = true;
      gnome.sushi.enable = true;
    };
    environment.systemPackages = with pkgs; [
      nautilus
      file-roller
      p7zip
      unrar
    ];
  };

  den.aspects.muggy-nixos.includes = [den.aspects.nautilus];
}
