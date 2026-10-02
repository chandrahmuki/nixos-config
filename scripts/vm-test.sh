#!/usr/bin/env bash
# Headless NixOS test VM: boots the real muggy-nixos config in QEMU with no
# window, so nothing touches the live desktop's focus, cursor or monitors.
#
#   scripts/vm-test.sh start         build + boot, wait for SSH and Hyprland
#   scripts/vm-test.sh shot [name]   screenshot -> prints the PNG path
#   scripts/vm-test.sh key KEY...    send keys, e.g. `key meta_l-s`
#   scripts/vm-test.sh mouse click X Y | drag X1 Y1 X2 Y2   pointer events (guest pixels)
#   scripts/vm-test.sh exec CMD...   run a command as the user inside the VM
#   scripts/vm-test.sh hypr ARGS...  hyprctl inside the VM
#   scripts/vm-test.sh log [unit]    journal of the VM (user unit if given)
#   scripts/vm-test.sh stop          power off and clean up
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
state=/tmp/muggy-vm
qmp="$state/qmp.sock"
user="${VM_USER:-david}"
ssh_opts=(-p 2222 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null
  -o LogLevel=ERROR -o PreferredAuthentications=password -o PubkeyAuthentication=no
  -o ConnectTimeout=5)

vm_ssh() {
  mkdir -p "$state"
  printf '#!/bin/sh\necho vm\n' >"$state/pw.sh"; chmod +x "$state/pw.sh"
  SSH_ASKPASS="$state/pw.sh" SSH_ASKPASS_REQUIRE=force \
    ssh "${ssh_opts[@]}" "$user@127.0.0.1" bash -s <<<"$*"
}

qmp_cmd() {
  printf '{"execute":"qmp_capabilities"}\n%s\n' "$1" | socat - "UNIX-CONNECT:$qmp" 2>/dev/null
}

hypr_env='export XDG_RUNTIME_DIR=/run/user/$(id -u); export HYPRLAND_INSTANCE_SIGNATURE=$(ls -t $XDG_RUNTIME_DIR/hypr/ | head -1);'

cmd_start() {
  mkdir -p "$state"
  if [[ -S "$qmp" ]] && qmp_cmd '{"execute":"query-status"}' | grep -q running; then
    echo "VM already running"; return 0
  fi
  rm -f "$qmp"
  local out
  out="$(nix build --impure --no-link --print-out-paths --expr "
    let flake = builtins.getFlake (toString $repo_root);
    in (flake.nixosConfigurations.muggy-nixos.extendModules { modules = [ $repo_root/scripts/vm-test.nix ]; }).config.system.build.vm" | tail -1)"
  local runner
  runner="$(ls "$out"/bin/run-*-vm)"
  ( cd "$state" && NIX_DISK_IMAGE="$state/disk.qcow2" setsid "$runner" >"$state/console.log" 2>&1 & )
  for _ in $(seq 1 120); do
    if vm_ssh true 2>/dev/null; then break; fi
    sleep 1
  done
  vm_ssh true
  for _ in $(seq 1 60); do
    if vm_ssh "$hypr_env hyprctl version" >/dev/null 2>&1; then
      echo "Hyprland up"; return 0
    fi
    sleep 1
  done
  echo "SSH up but Hyprland not reachable yet; see: $0 log" >&2
  return 1
}

cmd_shot() {
  # Needs `-vga std` + `-vnc`: on a headless virtio-gpu screendump is black
  # and grim hangs.
  local name="${1:-shot-$(date +%H%M%S)}"
  local png="$state/$name.png"
  qmp_cmd "{\"execute\":\"screendump\",\"arguments\":{\"filename\":\"$png\",\"format\":\"png\"}}" >/dev/null
  sleep 0.5
  echo "$png"
}

cmd_key() {
  # key meta_l-s  -> hold Super, press S
  local spec keys
  for spec in "$@"; do
    keys=""
    IFS='-' read -ra parts <<<"$spec"
    for k in "${parts[@]}"; do
      keys+="{\"type\":\"qcode\",\"data\":\"$k\"},"
    done
    qmp_cmd "{\"execute\":\"send-key\",\"arguments\":{\"keys\":[${keys%,}]}}" >/dev/null
    sleep 0.3
  done
}

cmd_mouse() {
  # mouse click X Y | mouse drag X1 Y1 X2 Y2   (pixels of the 1280x800 guest screen)
  local w="${VM_W:-1280}" h="${VM_H:-800}" op="$1"; shift
  abs() { printf '{"type":"abs","data":{"axis":"%s","value":%d}}' "$1" "$(( $2 * 32767 / $3 ))"; }
  move() { qmp_cmd "{\"execute\":\"input-send-event\",\"arguments\":{\"events\":[$(abs x "$1" "$w"),$(abs y "$2" "$h")]}}" >/dev/null; sleep 0.3; }
  btn() { qmp_cmd "{\"execute\":\"input-send-event\",\"arguments\":{\"events\":[{\"type\":\"btn\",\"data\":{\"down\":$1,\"button\":\"left\"}}]}}" >/dev/null; sleep 0.3; }
  case "$op" in
    click) move "$1" "$2"; btn true; btn false ;;
    drag) move "$1" "$2"; btn true; move "$3" "$4"; btn false ;;
    *) echo "usage: mouse click X Y | mouse drag X1 Y1 X2 Y2" >&2; return 2 ;;
  esac
}

cmd_stop() {
  if [[ -S "$qmp" ]]; then qmp_cmd '{"execute":"quit"}' >/dev/null || true; fi
  sleep 1
  rm -rf "$state"
}

case "${1:-}" in
  start) cmd_start ;;
  shot) shift; cmd_shot "$@" ;;
  key) shift; cmd_key "$@" ;;
  exec) shift; vm_ssh "$hypr_env $*" ;;
  hypr) shift; vm_ssh "$hypr_env hyprctl $*" ;;
  log) shift; if [[ $# -gt 0 ]]; then vm_ssh "journalctl --user -u $1 --no-pager | tail -60"; else vm_ssh "journalctl -b --no-pager | tail -80"; fi ;;
  mouse) shift; cmd_mouse "$@" ;;
  stop) cmd_stop ;;
  *) sed -n '2,12p' "$0"; exit 2 ;;
esac
