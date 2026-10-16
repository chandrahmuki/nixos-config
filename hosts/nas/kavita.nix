# Kavita: the reader for the mangas, the comics and the EPUB books.
#
# http://nas:5000 on the home network and through Tailscale. The first admin account is
# created in the browser on the first visit, so do that right after the first start. Then
# add a library of type Manga pointing at /data/media/manga and one of type Book pointing at
# /data/media/books (one folder per series or per book).
{pkgs, ...}: {
  services.kavita = {
    enable = true;
    settings.Port = 5000;
    # Not in the repository: generated once on the NAS by kavita-token-key below.
    tokenKeyFile = "/var/lib/kavita-secrets/token-key";
  };

  # Kavita only reads the books; they live on the data disk, in the group of the media.
  users.users.kavita.extraGroups = ["media"];

  # The books folder and the secret key are made once /data is mounted (a tmpfiles rule runs
  # before the mount and would fill the root disk). The key never changes afterwards:
  # changing it logs everyone out.
  systemd.services.kavita-token-key = {
    description = "Create the Kavita secret key and the books and manga folders";
    wantedBy = ["kavita.service"];
    before = ["kavita.service"];
    unitConfig.RequiresMountsFor = ["/data"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      install -d -m 0700 -o root -g root /var/lib/kavita-secrets
      if [ ! -s /var/lib/kavita-secrets/token-key ]; then
        umask 077
        head -c 64 /dev/urandom | base64 --wrap=0 > /var/lib/kavita-secrets/token-key
      fi
      install -d -m 2775 -o david -g media /data/media/books /data/media/manga
    '';
    path = [pkgs.coreutils];
  };

  systemd.services.kavita = {
    requires = ["kavita-token-key.service"];
    after = ["kavita-token-key.service"];
    unitConfig.RequiresMountsFor = ["/data"];
  };

  # The wired network only; Tailscale is a trusted interface already.
  networking.firewall.interfaces.eno1.allowedTCPPorts = [5000];
}
