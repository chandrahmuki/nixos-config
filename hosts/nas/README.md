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

## Shared folder (SMB)

`samba.nix` shares `/data/partage` as `partage`, for the home network and Tailscale only
(no guests). Set the Samba password of the admin once, it is not in the repository:
`sudo smbpasswd -a david`. Connect with user `david`:

- Mac Finder, iPhone Files, Linux file manager: `smb://192.168.178.34` at home,
  `smb://100.127.232.108` through Tailscale. The short name `smb://nas` does not work from
  the iPhone (it sits behind the Deco mesh node, which does not resolve it); checked with
  the IP address.
- Windows: `\\192.168.178.34\partage`.

## Services and folders

| Service | Address (home / Tailscale) | Data |
|---|---|---|
| Nextcloud | `http://nas/` | `/data/nextcloud` |
| Navidrome (music) | `:4533` | `/data/media/music` |
| Jellyfin (video) | `:8096`, libraries Movies and Shows | `/data/media/video/{Movies,Shows}` |
| Immich (photos) | `:2283` | `/data/immich` |
| Kavita (manga, books) | `:5000`, libraries Manga and Book | `/data/media/{manga,books}` |
| SMB share | `smb://192.168.178.34/partage` | `/data/partage` |

- Immich comes from its own pinned nixpkgs (`nixpkgs-immich` in `flake.nix`): the iOS app
  moves faster than nixos-unstable, and the app wants the same version as the server. Bump
  the rev on purpose when the app moves on.
- Jellyfin names: `Movies/Name (year) [imdbid-tt0000000]/Name (year) [imdbid-tt0000000].mkv`
  and `Shows/Name (year)/Season 01/Name - S01E01.mkv`. A library of the wrong type (Shows for
  films) gives wrong covers and no search results.
- Kavita does not scan files at the root of a library: one folder per series or per book.
- The first admin account of Navidrome, Jellyfin, Immich and Kavita is created in the
  browser on the first visit.

## Backup

`backup.nix` copies every night at 03:30 to the Toshiba 1 TB disk (btrfs, label `backup`,
mounted on `/backup`): `/data` without the films and without the Immich thumbnails, a dump of
the Nextcloud and Immich databases, and the settings of Jellyfin, Navidrome and Kavita. A
read-only btrfs snapshot keeps each night, the 30 newest are kept (`/backup/snapshots`). Run
it by hand with `sudo systemctl start nas-backup`; it refuses to run when a disk is missing.
It is on the same machine: it does not protect against fire, theft or a power surge.

To take a file back: `/backup/current/data/...` is the last night, an older night is in
`/backup/snapshots/<date>/data/...`.

## Not included on purpose

Forgejo (git), hardware video transcoding. A NAS is not a
backup: keep a second copy of anything that matters somewhere else.
