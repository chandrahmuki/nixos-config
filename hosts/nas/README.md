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
| Jellyfin (video) | `:8096`, libraries Movies and Shows | `/data/media/video/{Movies,Shows}` and `/video2/{Movies,Shows}` |
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

## Second disk part for the films

The WD 2 TB disk has two parts: sdb1 (ext4, `/data`) and sdb2 (btrfs, `/video2`, 980 GB, formerly
NTFS with old data, erased on purpose). `video2.nix` mounts it; the films are not backed up
(`/video2` and `/data/media/video` are excluded). Add `/video2/Movies` and `/video2/Shows` to the
Jellyfin libraries. Put new films there: it has the room.

## Backup

`backup.nix` copies every night at 03:30 to the Toshiba 1 TB disk (btrfs, label `backup`,
mounted on `/backup`): `/data` without the films and without the Immich thumbnails, a dump of
the Nextcloud and Immich databases, and the settings of Jellyfin, Navidrome and Kavita. A
read-only btrfs snapshot keeps each night, the 30 newest are kept (`/backup/snapshots`). Run
it by hand with `sudo systemctl start nas-backup`; it refuses to run when a disk is missing.
It is on the same machine: it does not protect against fire, theft or a power surge.

To take a file back: `/backup/current/data/...` is the last night, an older night is in
`/backup/snapshots/<date>/data/...`.

## Reference sheet (current state, 2026-10-18)

Read this first for any NAS task. Anything here can be stale: check the machine.

- **Machine**: AOOSTAR WTR PRO (Ryzen 7 5825U, 32 GB, 2 x I226-V, 2 empty M.2 slots). Host
  `nas`, flake output `nas`, reachable as `ssh david@nas` (key only) or
  `192.168.178.34` (home) / `100.127.232.108` (Tailscale). The Ventoy USB must stay
  unplugged: the firmware boots it before the SSD.
- **Disks**: `sda` Samsung 500 GB SSD = system (btrfs `@ @nix @log @home`); `sdb1` `/data`
  (ext4, 869 GB: Nextcloud, Immich, media, `partage`); `sdb2` `/video2` (btrfs, films);
  `sdc` Toshiba 1 TB `/backup` (btrfs, nightly 03:30, 30 snapshots, films excluded).
- **Names**: `jellyfin.nas`, `navidrome.nas`, `immich.nas`, `kavita.nas`, `adguard.nas`
  (nginx + AdGuard rewrites). DNS goes through Tailscale (admin console nameserver
  `100.127.232.108`, override on): names and ad blocking only work with Tailscale on. The
  phone is behind a Deco mesh node: the short name `nas` does not resolve there.
- **SSH keys of `david`** are declared in `default.nix` (`openssh.authorizedKeys.keys`):
  the desktop and the Mac. The repository is public on GitHub: only public keys, never a
  private key, no mail address in the comment.
- **Deploying**: `nos` on the desktop first (it defines `nasos` and `nasw`, `aspects/nh.nix`),
  then `nasos` (copies the repository, `sudo nixos-rebuild switch` on the NAS, asks the
  sudo password of `david` in the user's terminal) and `nasw` (pre-builds on every save in
  `hosts/nas`). The agent has no sudo: it prepares and builds
  (`nix build .#nixosConfigurations.nas.config.system.build.toplevel`), the user activates.
  A command run with `!` in Claude Code has no terminal: sudo cannot ask there.
- **Books (Kavita)**: the user drops EPUB in `/data/partage/Livres`; copy them (never move)
  into `/data/media/books`, one folder per book or series, skip duplicates by checksum, then
  the user scans the library in Kavita (no API access for the agent). 111 EPUB there on
  2026-10-18. Manga (CBZ) in `/data/media/manga`, one folder per series.
- **Still manual / user side**: accounts of Navidrome and Jellyfin, `sudo tailscale up`, the
  Nextcloud admin password (only in `/var/lib/nextcloud-secrets/admin-pass`), the Samba
  password (`smbpasswd`), test of the Mac SSH key.
- **Decisions**: keep the VPS (no website on the NAS); HTTPS with a real domain undecided;
  no Docker or VMs (NixOS modules); moving `scripts/vm-test.sh` to the NAS is feasible
  (KVM) and not started; Google Drive and Photos are cancelled, their copy lives in
  Nextcloud and Immich; add `nas.fritz.box` to the Nextcloud trusted domains if wanted.
- **Never**: touch the user's data without a precise yes, wipe a disk, print a secret,
  open a sudo prompt in a hidden terminal.

### Every service, in one place

| Service | What it does | Reach it | Notes |
|---|---|---|---|
| SSH | remote shell, key only | `ssh david@nas` | root login off, no password |
| Tailscale | private network to the NAS from outside, no router port open | `100.127.232.108` | `tailscale0` is a trusted interface; login by hand |
| Nextcloud | files, Google Drive copy | `http://nas/` | nginx + phpfpm, `trusted_domains` in `nextcloud.nix`; video/HEIC thumbnails made in the background |
| Navidrome | music | `http://navidrome.nas`, `:4533` | `/data/media/music` |
| Jellyfin | films and shows | `http://jellyfin.nas`, `:8096` | libraries Movies and Shows on `/data/media/video` and `/video2` |
| Immich | phone photos | `http://immich.nas`, `:2283` | own pinned nixpkgs, trash keeps 30 days |
| Kavita | manga (CBZ) and books (EPUB) | `http://kavita.nas`, `:5000` | one folder per series, scan by hand in the UI |
| Samba | shared folder `partage` | `smb://192.168.178.34/partage` | `/data/partage`, LAN + Tailscale, no guests |
| AdGuard Home | DNS that blocks ads and answers `*.nas` | page `http://adguard.nas`, port 300; DNS 53 | only used through Tailscale (see Names above) |
| nginx | reverse proxy for the `*.nas` names | ports 80 | `names.nix` |
| Avahi | `nas.local` on the home network | - | does not resolve from the desktop |
| smartd | disk health warnings | `sudo smartctl -a /dev/sdX` | - |
| nas-backup | nightly copy to `/backup` + snapshot | `sudo systemctl start nas-backup` | timer 03:30, see Backup |

Firewall: the service ports are open on the LAN interface `eno1` only (module by module),
everything on `tailscale0`. Services that read `/data` wait for its mount
(`RequiresMountsFor` in `default.nix`).

### How the agent connects, and how `nasos` / `nasw` work

- **The agent** (Claude Code, run from the desktop) uses `ssh david@nas` with the desktop
  key, no password, and runs read-only checks (`systemctl`, `journalctl`, `df`, `ls`) and
  file work as `david` (the `media` group owns `/data/media`, the share is group-writable).
  It has no sudo: anything that needs root is a command the user types in a visible
  terminal. It cannot open the web UIs with a login (Kavita scan, accounts).
- **`nos`** activates the desktop. It is also what installs the fish functions below.
- **`nasos`** = `rsync` of the repository to `~/nixos-config` on the NAS (no `.git`, no
  `result`, `--delete`), then `ssh -t david@nas sudo nixos-rebuild switch --flake
  path:$HOME/nixos-config#nas`. The NAS builds itself because `nixos-rebuild --target-host`
  fails on store trust. It asks the sudo password of `david`.
- **`nasw`** = after each save in `hosts/nas`, the same `rsync` then `nixos-rebuild build`
  on the NAS (never activates), so `nasos` only has to switch. Ctrl+C stops it.
- **Check after a deploy**: `ssh david@nas readlink /run/current-system` must equal the
  path printed by `nix build .#nixosConfigurations.nas.config.system.build.toplevel
  --no-link --print-out-paths` on the desktop; then `systemctl --failed`.
- **Kavita in HTTPS for iOS apps** (ATS refuses plain HTTP): set by hand on the NAS, not
  declared in Nix: `sudo tailscale serve --bg --https=8443 http://127.0.0.1:5000`, after
  enabling HTTPS Certificates in the Tailscale admin console. URL for the apps (Tailscale must
  be on): `https://nas.tailbc7882.ts.net:8443`. Works on the phone (2026-10-18).
- **Mac**: its public key is in `default.nix`; it connects to `192.168.178.34`.

## Not included on purpose

Forgejo (git), hardware video transcoding. A NAS is not a
backup: keep a second copy of anything that matters somewhere else.
