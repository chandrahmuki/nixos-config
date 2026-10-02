#!/usr/bin/env bash
# Flash the Preonic rev3 once it is in its STM32 DFU bootloader.
#
#   scripts/qmk-flash.sh [firmware.bin]     (default: qmk/preonic_rev3_muggy.bin)
#
# It waits for the bootloader (0483:df11), refuses to continue if the normal
# keyboard (03a8:a649) is still visible (then the DFU device is something else),
# saves the current firmware to qmk/backup/, checks that backup, and only then
# flashes. If anything looks wrong it stops before writing.
set -u
repo="$(cd "$(dirname "$0")/.." && pwd)"
fw="${1:-$repo/qmk/preonic_rev3_muggy.bin}"
backup="$repo/qmk/backup/firmware-before-flash-$(date +%Y%m%d-%H%M%S).bin"

usb_has() {
  for d in /sys/bus/usb/devices/*/; do
    [ "$(cat "$d/idVendor" 2>/dev/null):$(cat "$d/idProduct" 2>/dev/null)" = "$1" ] && return 0
  done
  return 1
}

[ -s "$fw" ] || { echo "ABANDON: firmware introuvable ($fw)"; exit 10; }
wait_s="${QMK_WAIT:-180}"
echo "attente du bootloader DFU (${wait_s} s)..."
for _ in $(seq 1 $((wait_s * 2))); do usb_has 0483:df11 && break; sleep 0.5; done
usb_has 0483:df11 || { echo "TIMEOUT: aucun bootloader apparu, rien n'a été écrit"; exit 1; }
sleep 1.5
if usb_has 03a8:a649; then
  echo "ABANDON: le Preonic est toujours visible en mode normal; ce DFU est un autre appareil. Rien écrit."
  exit 2
fi
echo "bootloader détecté"

echo "--- sauvegarde du firmware actuel ---"
dfu-util -a 0 -d 0483:df11 -s 0x08000000:0x40000 -U "$backup" 2>&1 | tail -2
python3 - "$backup" <<'PY'
import sys
d = open(sys.argv[1], "rb").read()
nonff = sum(1 for b in d if b != 0xFF)
print(f"sauvegarde: {len(d)} octets, {nonff} octets utiles")
sys.exit(0 if len(d) == 0x40000 and nonff > 10000 else 1)
PY
[ $? -eq 0 ] || { echo "ABANDON: sauvegarde invalide, rien flashé (le clavier reste en bootloader)"; exit 3; }
echo "sauvegarde: $backup"

echo "--- flash de $(basename "$fw") ---"
dfu-util -a 0 -d 0483:df11 -s 0x08000000:leave -D "$fw" 2>&1 | tail -4
rc=${PIPESTATUS[0]}
echo "dfu-util rc=$rc"
for _ in $(seq 1 40); do
  usb_has 03a8:a649 && { echo "Preonic revenu en mode normal (03a8:a649) ✔"; exit 0; }
  sleep 0.5
done
echo "Le Preonic n'est pas revenu en mode normal : bouton reset au dos, ou rebranche-le."
exit 4
