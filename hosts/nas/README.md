# NAS host

Headless home NAS, separate from the desktop (`muggy-nixos`): Nextcloud (files),
Navidrome (music), Jellyfin (video), Tailscale (remote access), smartd (disk health).

`hardware-configuration.nix` is a placeholder. Everything else was exercised in a
VM with `scripts/nas-test.sh`; what could not be tested there is marked below.

## First install (on the machine)

1. Boot the NixOS installer, partition and mount the disks. Mount the data disk on
   `/data` (Nextcloud files in `/data/nextcloud`, media in `/data/media/{music,video}`).
2. `nixos-generate-config --show-hardware-config` and replace
   `hosts/nas/hardware-configuration.nix` with the output.
3. Create the Nextcloud admin password, outside the repository, before the first start:
   `install -d -m 700 /var/lib/nextcloud-secrets` then
   `install -m 600 /dev/stdin /var/lib/nextcloud-secrets/admin-pass <<<'a long password'`
4. `nixos-install --flake .#nas`, then set a password for `david` (`passwd`), which
   `sudo` needs; SSH itself is key-only.
5. Check the old 1 TB disk before trusting it: `sudo smartctl -a /dev/sdX`.

## Remote access (not testable in the VM)

`sudo tailscale up` on the NAS, then install Tailscale on the phone with the same
account. Add the tailnet name of the NAS (`nas.<tailnet>.ts.net`) to
`services.nextcloud.settings.trusted_domains` in `nextcloud.nix`.
Ports are not opened on the router.

## Not included on purpose

Immich (photos), Forgejo (git), hardware video transcoding, backups. A NAS is not a
backup: keep a second copy of anything that matters somewhere else.
