# QMK keymap for the OLKB Preonic rev3

QMK userspace holding the keymap of the main keyboard (USB 03a8:a649, STM32F303,
`stm32-dfu` bootloader). The keymap is `keyboards/preonic/rev3/keymaps/muggy/`.
VIA is off: `keymap.c` is the single source of truth.

`backup/` has the layout read from the keyboard on 2026-10-02, before the first
QMK flash (JSON with the raw codes, and a readable text version).

## Bottom row: do not read the matrix as two halves

In the matrix of this board the bottom row is interleaved:
`8,0 8,1 8,2 9,3 9,4 9,5 | 9,0 9,1 9,2 8,3 8,4 8,5`. Reading it as "left half then
right half" puts Super where the left arrow is. The physical bottom row is

    [ ] Ctrl Alt Super LOWER Space Space RAISE / Left Down Right

Always check a keymap against the official mapping in
`~/qmk_firmware/keyboards/preonic/rev3/keyboard.json`, not against a layout you
derived yourself. In the old VIA firmware the two layer keys were custom keycodes:
0x5F10 (Lower) turned on layer 1, 0x5F11 (Raise) layer 2 (read from its machine code).

## Build

```sh
# once: the QMK firmware sources live outside the repository
git clone --depth 1 --recurse-submodules --shallow-submodules \
  https://github.com/qmk/qmk_firmware ~/qmk_firmware

export QMK_HOME=~/qmk_firmware QMK_USERSPACE=~/nixos-config/qmk
qmk compile -kb preonic/rev3 -km muggy       # -> qmk/preonic_rev3_muggy.bin
```

`qmk` and `dfu-util` come from the `qmk` aspect, which also installs the udev rules
that let a keyboard in bootloader mode be flashed without root.

## Flash

```sh
scripts/qmk-flash.sh            # then put the keyboard in bootloader mode
```

The script waits for the bootloader (0483:df11), refuses to go on if the normal
keyboard is still visible, saves the current firmware to
`qmk/backup/firmware-before-flash-<date>.bin` (ignored by git), checks the backup,
and only then flashes. `QMK_WAIT=300` extends the 180 s wait.

Enter the bootloader with one of:
- hold Lower and Raise (the two keys either side of the space bar) and press the key
  at row 1, column 1 (`Q`): `QK_BOOT` on the Adjust layer. Check the physical
  positions against the keymap you currently have flashed;
- unplug the USB cable, hold the top-left key and plug it back in (Bootmagic);
- press the reset button on the back of the board.

An STM32 in DFU mode cannot be bricked: the bootloader is in ROM. To go back to the
original VIA firmware:
`dfu-util -a 0 -d 0483:df11 -s 0x08000000:leave -D qmk/backup/old-firmware-20261002.bin`
(that file is the full 256 KB image read from the board before the first flash).
