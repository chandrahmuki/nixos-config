# Test-only overrides for the NAS VM (scripts/nas-test.sh). Never part of the real host.
{
  lib,
  pkgs,
  ...
}: {
  virtualisation.vmVariant = {
    virtualisation = {
      memorySize = 4096;
      cores = 4;
      diskSize = 8192;
      graphics = false;
      forwardPorts = [
        {
          from = "host";
          host.port = 2223;
          guest.port = 22;
        }
        {
          from = "host";
          host.port = 8080;
          guest.port = 80;
        }
        {
          from = "host";
          host.port = 4533;
          guest.port = 4533;
        }
        {
          from = "host";
          host.port = 8096;
          guest.port = 8096;
        }
      ];
      qemu.options = ["-qmp" "unix:/tmp/muggy-nas-vm/qmp.sock,server=on,wait=off"];
    };

    # Password login only inside the throwaway VM.
    services.openssh.settings.PasswordAuthentication = lib.mkForce true;
    users.users.david.initialPassword = "vm";

    # Same shape as the real secret: a root-only file outside the Nix store.
    system.activationScripts.nasTestSecret = ''
      mkdir -p /var/lib/nextcloud-secrets
      echo -n 'test-only-password' > /var/lib/nextcloud-secrets/admin-pass
      chmod 600 /var/lib/nextcloud-secrets/admin-pass
    '';

    # No SMART devices in a VM.
    services.smartd.enable = lib.mkForce false;
    environment.systemPackages = [pkgs.curl];
  };
}
