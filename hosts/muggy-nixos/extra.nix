# Packages for this machine only. handy transcribes speech (F1 in Hyprland) and
# wtype types the result into the focused window.
{pkgs, ...}: {
  # Let the logged-in desktop user access the XTEink X4's ESP32 serial
  # bootloader without running chmod after every USB reconnect.
  services.udev.extraRules = ''
    SUBSYSTEM=="tty", ATTRS{idVendor}=="303a", ATTRS{idProduct}=="1001", TAG+="uaccess"
  '';

  environment.systemPackages = [
    pkgs.handy
    pkgs.wtype
  ];
}
