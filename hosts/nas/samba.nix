# A shared folder (SMB) for the Mac, the PCs and the phone: smb://nas. Reachable from the
# home network and from Tailscale only, never from the Internet.
#
# The Samba password of the admin is not in the repository: set it once on the NAS with
#   sudo smbpasswd -a david
# (README.md).
{pkgs, ...}: let
  admin = "david";
in {
  services.samba = {
    enable = true;
    openFirewall = false;
    settings = {
      global = {
        "server string" = "NAS";
        "server role" = "standalone server";
        security = "user";
        "map to guest" = "never";
        # The home network and Tailscale, nothing else.
        "hosts allow" = "127.0.0.1 192.168.178.0/24 100.64.0.0/10";
        "hosts deny" = "0.0.0.0/0";
        "server min protocol" = "SMB3";
        # Encrypt when the client can; Tailscale already encrypts the way in from outside.
        "server smb encrypt" = "desired";
        # What the Mac Finder expects, so it does not litter the folders.
        "vfs objects" = "fruit streams_xattr";
        "fruit:metadata" = "stream";
        "fruit:model" = "MacSamba";
        "fruit:nfs_aces" = "no";
      };
      partage = {
        path = "/data/partage";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "valid users" = admin;
        "force group" = "media";
        "create mask" = "0664";
        "directory mask" = "2775";
      };
    };
  };

  # Windows finds the NAS by itself; the Macs find it through avahi (already on).
  services.samba-wsdd = {
    enable = true;
    openFirewall = false;
  };
  services.avahi.extraServiceFiles.smb = ''
    <?xml version="1.0" standalone='no'?>
    <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
    <service-group>
      <name replace-wildcards="yes">%h</name>
      <service>
        <type>_smb._tcp</type>
        <port>445</port>
      </service>
    </service-group>
  '';

  # Ports on the wired network only. Tailscale is a trusted interface already.
  networking.firewall.interfaces.eno1 = {
    allowedTCPPorts = [445 5357];
    allowedUDPPorts = [3702];
  };

  # The folder lives on the data disk: wait for it, and create the folder once it is
  # there (a tmpfiles rule would run before the mount and fill the root disk instead).
  systemd.services.samba-smbd = {
    unitConfig.RequiresMountsFor = ["/data"];
    serviceConfig.ExecStartPre = "+${pkgs.coreutils}/bin/install -d -m 2775 -o ${admin} -g media /data/partage";
  };
}
