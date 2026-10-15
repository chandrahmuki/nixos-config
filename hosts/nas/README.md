# NAS host

Headless home NAS, separate from the desktop (`muggy-nixos`): Nextcloud (files),
Navidrome (music), Jellyfin (video), Tailscale (remote access), smartd (disk health).

`hardware-configuration.nix` comes from the machine (AOOSTAR WTR PRO, Ryzen 7 5825U,
32 GB): system on the 500 GB SATA SSD in btrfs like the desktop (`@`, `@nix`, `@log`,
`@home`), `/data` on the empty ext4 partition of the 2 TB disk for now. The two M.2 slots
are empty. Everything else was exercised in a VM with `scripts/nas-test.sh`; what could
not be tested there is marked below.

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
account. Done on 2026-10-15: the NAS is `nas.tailbc7882.ts.net` (100.127.232.108) and
both are in `services.nextcloud.settings.trusted_domains` in `nextcloud.nix`, with the
names and address it has on the home network. Nextcloud answers on every one of them
(checked with a Host header); anything else gets "Trusted domain error".
Ports are not opened on the router. The web services are plain HTTP: over Tailscale
the traffic is encrypted by WireGuard, on the home network it is not.

Deploying: `nixos-rebuild --target-host` fails ("lacks a signature by a trusted key"):
`david` is not a trusted user of the NAS store, on purpose. Copy the repository to the
NAS (`rsync -a --exclude=.git ./ david@nas:nixos-config/`), then on the NAS
`sudo nixos-rebuild switch --flake path:$HOME/nixos-config#nas`.

## Not included on purpose

Immich (photos), Forgejo (git), hardware video transcoding, backups. A NAS is not a
backup: keep a second copy of anything that matters somewhere else.
