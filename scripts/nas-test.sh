#!/usr/bin/env bash
# Boots the NAS host in a headless QEMU VM, exercises every service, then always
# powers the VM off. Nothing touches the live desktop.
#
#   scripts/nas-test.sh
#
# Forwarded ports: ssh 2223, Nextcloud 8080, Navidrome 4533, Jellyfin 8096.
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
state=/tmp/muggy-nas-vm
qmp="$state/qmp.sock"
pass=test-only-password
failures=0

ssh_opts=(-p 2223 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null
  -o LogLevel=ERROR -o PreferredAuthentications=password -o PubkeyAuthentication=no
  -o ConnectTimeout=5)

vm_ssh() {
  printf '#!/bin/sh\necho vm\n' >"$state/pw.sh"; chmod +x "$state/pw.sh"
  SSH_ASKPASS="$state/pw.sh" SSH_ASKPASS_REQUIRE=force \
    ssh "${ssh_opts[@]}" david@127.0.0.1 bash -s <<<"$*"
}

stop_vm() {
  if [[ -S "$qmp" ]]; then
    printf '{"execute":"qmp_capabilities"}\n{"execute":"quit"}\n' | socat - "UNIX-CONNECT:$qmp" >/dev/null 2>&1 || true
    sleep 2
  fi
  rm -rf "$state"
}
trap stop_vm EXIT

check() { # name, command that must succeed
  local name="$1"; shift
  if out="$("$@" 2>&1)"; then
    printf 'OK    %s\n' "$name"
  else
    printf 'FAIL  %s\n      %s\n' "$name" "$(head -c 300 <<<"$out")"
    failures=$((failures + 1))
  fi
}

rm -rf "$state"; mkdir -p "$state"
echo "== build"
vm_path="$(nix build --impure --no-link --print-out-paths --expr "
  let flake = builtins.getFlake (toString $repo_root);
  in (flake.nixosConfigurations.nas.extendModules { modules = [ $repo_root/scripts/nas-test.nix ]; }).config.system.build.vm" | tail -1)"
runner="$(ls "$vm_path"/bin/run-*-vm)"
echo "$runner"

echo "== boot"
( cd "$state" && NIX_DISK_IMAGE="$state/disk.qcow2" setsid "$runner" >"$state/console.log" 2>&1 & )
for _ in $(seq 1 180); do vm_ssh true 2>/dev/null && break; sleep 1; done
vm_ssh true

echo "== wait for Nextcloud first-run setup (can take a few minutes)"
for _ in $(seq 1 300); do
  curl -fs -H 'Host: nas' http://127.0.0.1:8080/status.php 2>/dev/null | grep -q '"installed":true' && break
  sleep 1
done

echo "== checks"
failed="$(vm_ssh 'systemctl --failed --no-legend' || true)"
if [[ -z "$failed" ]]; then echo "OK    systemd: aucune unité en échec"; else echo "FAIL  unités en échec:"; echo "$failed"; failures=$((failures + 1)); fi

for u in nextcloud-setup phpfpm-nextcloud nginx postgresql redis-nextcloud navidrome jellyfin avahi-daemon tailscaled sshd; do
  s="$(vm_ssh "systemctl is-active $u.service" 2>/dev/null || true)"
  # nextcloud-setup is a oneshot that ends "active" (RemainAfterExit) or "inactive"
  if [[ "$s" == active || ( "$u" == nextcloud-setup && "$s" == inactive ) ]]; then
    echo "OK    $u: $s"
  else
    echo "FAIL  $u: $s"; failures=$((failures + 1))
  fi
done

check "Nextcloud status.php installed" bash -c "curl -fs -H 'Host: nas' http://127.0.0.1:8080/status.php | grep -q '\"installed\":true'"

echo "nas-test $(date +%s)" >"$state/up.txt"
code="$(curl -s -o /dev/null -w '%{http_code}' -u "admin:$pass" -H 'Host: nas' -T "$state/up.txt" http://127.0.0.1:8080/remote.php/dav/files/admin/nas-test.txt)"
[[ "$code" == 201 || "$code" == 204 ]] && echo "OK    Nextcloud: envoi WebDAV ($code)" || { echo "FAIL  Nextcloud: envoi WebDAV ($code)"; failures=$((failures + 1)); }
back="$(curl -s -u "admin:$pass" -H 'Host: nas' http://127.0.0.1:8080/remote.php/dav/files/admin/nas-test.txt || true)"
[[ "$back" == "$(cat "$state/up.txt")" ]] && echo "OK    Nextcloud: relecture identique" || { echo "FAIL  Nextcloud: relecture ('$back')"; failures=$((failures + 1)); }
ondisk="$(vm_ssh 'echo vm | sudo -S ls /data/nextcloud/data/admin/files 2>/dev/null' || true)"
grep -q nas-test.txt <<<"$ondisk" && echo "OK    Nextcloud: fichier présent dans /data/nextcloud" || { echo "FAIL  Nextcloud: rien dans /data/nextcloud"; failures=$((failures + 1)); }

check "Jellyfin /health" bash -c "curl -fs http://127.0.0.1:8096/health | grep -q Healthy"
check "Jellyfin /System/Info/Public" bash -c "curl -fs http://127.0.0.1:8096/System/Info/Public | grep -q ServerName"

check "Navidrome /ping" curl -fs http://127.0.0.1:4533/ping
nix shell nixpkgs#ffmpeg-headless -c ffmpeg -loglevel error -f lavfi -i "sine=frequency=440:duration=2" \
  -metadata title=NasTestTrack -metadata artist=NasTestArtist -metadata album=NasTestAlbum "$state/tone.flac"
printf '#!/bin/sh\necho vm\n' >"$state/pw.sh"; chmod +x "$state/pw.sh"
SSH_ASKPASS="$state/pw.sh" SSH_ASKPASS_REQUIRE=force ssh "${ssh_opts[@]}" david@127.0.0.1 'cat > /data/media/music/tone.flac' <"$state/tone.flac" || true
vm_ssh 'test -s /data/media/music/tone.flac' && echo "OK    musique: fichier déposé par david dans /data/media/music" || { echo "FAIL  musique: dépôt impossible"; failures=$((failures + 1)); }
curl -fs -X POST -H 'Content-Type: application/json' -d '{"username":"test","password":"testpass1"}' http://127.0.0.1:4533/auth/createAdmin >/dev/null || true
q="u=test&p=testpass1&v=1.16.1&c=nastest&f=json"
curl -fs "http://127.0.0.1:4533/rest/startScan?$q" >/dev/null || true
found=""
for _ in $(seq 1 30); do
  found="$(curl -fs "http://127.0.0.1:4533/rest/search3?$q&query=NasTestArtist" 2>/dev/null || true)"
  grep -q NasTestArtist <<<"$found" && break
  sleep 2
done
grep -q NasTestArtist <<<"$found" && echo "OK    Navidrome: morceau indexé et trouvé par recherche" || { echo "FAIL  Navidrome: morceau non trouvé"; failures=$((failures + 1)); }

echo "== erreurs dans le journal (priorité err et plus)"
errs="$(vm_ssh 'journalctl -b -p err --no-pager -q' || true)"
if [[ -z "$errs" ]]; then echo "OK    aucune erreur"; else echo "$errs" | head -30; fi

echo
if ((failures == 0)); then echo "RÉSULTAT: tout est passé"; else echo "RÉSULTAT: $failures échec(s)"; fi
exit "$failures"
