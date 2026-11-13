# Packages for this machine only. handy transcribes speech (F1 in Hyprland) and
# wtype types the result into the focused window.
{pkgs, ...}: let
  bitwigArchive = builtins.fetchurl {
    url = "file:///home/david/Downloads/cjXYXh8A_bitwig-studio-6-v6-1-linux-team-totoro.rar";
    sha256 = "sha256-AW6XGD6AV1FfxBo7bSEXkb3bQFrExz+hYg/eNeWz+0w=";
  };
  bitwigFiles =
    pkgs.runCommand "bitwig-6.1-downloaded-files" {
      nativeBuildInputs = [pkgs.unrar];
    } ''
      mkdir -p "$out" work
      cd work
      unrar x -o- -p- ${bitwigArchive}
      cp Bitwig.Studio.6.v6.1.LiNUX-Team.Totoro/bitwig-studio-6.1.deb "$out/bitwig.deb"
      cp Bitwig.Studio.6.v6.1.LiNUX-Team.Totoro/bitwig.jar "$out/bitwig.jar"
    '';
  bitwig = pkgs.bitwig-studio.overrideAttrs (old: {
    version = "6.1";
    src = "${bitwigFiles}/bitwig.deb";
    postInstall =
      (old.postInstall or "")
      + ''
        cp ${bitwigFiles}/bitwig.jar "$out/libexec/bin/bitwig.jar"
      '';
  });
in {
  # Let the logged-in desktop user access the XTEink X4's ESP32 serial
  # bootloader without running chmod after every USB reconnect.
  services.udev.extraRules = ''
    SUBSYSTEM=="tty", ATTRS{idVendor}=="303a", ATTRS{idProduct}=="1001", TAG+="uaccess"
  '';

  environment.systemPackages = [
    pkgs.handy
    pkgs.wtype
    bitwig
  ];
}
