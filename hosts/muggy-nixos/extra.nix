# Packages for this machine only. handy transcribes speech (F1 in Hyprland) and
# wtype types the result into the focused window.
{pkgs, ...}: {
  environment.systemPackages = [
    pkgs.handy
    pkgs.wtype
  ];
}
