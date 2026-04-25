{ config, lib, pkgs, ... }:

{
  services.gvfs.enable = true;
  services.tumbler.enable = true;
  services.gnome.sushi.enable = true;

  environment.systemPackages = with pkgs; [
    nautilus
    file-roller
    unzip
    p7zip
    unrar
    filezilla
  ];
}
