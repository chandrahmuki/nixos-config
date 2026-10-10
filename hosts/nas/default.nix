# Lightweight home NAS: files (Nextcloud), music (Navidrome) and video (Jellyfin).
# A separate host from the desktop: no Hyprland, no theming, no Home Manager.
#
# First boot checklist: README.md in this directory.
{pkgs, ...}: let
  admin = "david";
in {
  imports = [
    ./hardware-configuration.nix
    ./nextcloud.nix
    ./media.nix
    ./tailscale.nix
  ];

  networking.hostName = "nas";
  time.timeZone = "Europe/Vienna";
  i18n.defaultLocale = "en_US.UTF-8";
  system.stateVersion = "26.11";

  nix.settings.experimental-features = ["nix-command" "flakes"];

  users.users.${admin} = {
    isNormalUser = true;
    extraGroups = ["wheel" "media"];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILZrsY/ghWdJ4vtUQ2r1vxc+8h+6NLN9qQy29Z+9KvRJ muggy@muggy.com"
    ];
  };

  # Key-only SSH; the LAN firewall opens the service ports in the modules below.
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # nas.local on the home network.
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      addresses = true;
    };
  };

  # Early warning for the old disks.
  services.smartd.enable = true;

  environment.systemPackages = [pkgs.smartmontools];
}
