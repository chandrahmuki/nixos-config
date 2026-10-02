#include QMK_KEYBOARD_H

enum layers { _QWERTY, _LOWER, _RAISE, _ADJUST };

// The two layer keys of the bottom row, which reads (physical order):
//   [ ] Ctrl Alt Super LOWER Space Space RAISE / Left Down Right
// LOWER (left of the space bar) turns on layer 1: F1-F12, navigation, media.
// RAISE (right of the space bar) turns on layer 2: digits, "-" and "=", F-keys.
// Holding both gives the Adjust layer. This is what the old firmware did; it was
// read from its machine code (backup/old-firmware-20261002.bin).
#define LOWER_KEY MO(_LOWER)
#define RAISE_KEY MO(_RAISE)

// Rows are in the physical order of LAYOUT_ortho_5x12. The bottom row of the
// matrix is interleaved (8,0 8,1 8,2 9,3 9,4 9,5 9,0 9,1 9,2 8,3 8,4 8,5), so it
// must never be read as "left half then right half".
const uint16_t PROGMEM keymaps[][MATRIX_ROWS][MATRIX_COLS] = {
    // Base. Copy of the layout read from the keyboard on 2026-10-02
    // (qmk/backup/preonic-rev3-original-layout.txt).
    [_QWERTY] = LAYOUT_ortho_5x12(
        KC_GRV,  KC_1,    KC_2,    KC_3,    KC_4,    KC_5,    KC_6,    KC_7,    KC_8,    KC_9,    KC_0,    KC_DEL,
        KC_TAB,  KC_Q,    KC_W,    KC_E,    KC_R,    KC_T,    KC_Y,    KC_U,    KC_I,    KC_O,    KC_P,    KC_BSPC,
        KC_ESC,  KC_A,    KC_S,    KC_D,    KC_F,    KC_G,    KC_H,    KC_J,    KC_K,    KC_L,    KC_SCLN, KC_QUOT,
        KC_LSFT, KC_Z,    KC_X,    KC_C,    KC_V,    KC_B,    KC_N,    KC_M,    KC_COMM, KC_DOT,  KC_UP,   SC_SENT,
        KC_NO,   KC_LCTL, KC_LALT, KC_LGUI, LOWER_KEY, KC_SPC, KC_SPC,  RAISE_KEY, KC_SLSH, KC_LEFT, KC_DOWN, KC_RGHT
    ),

    // Lower: function keys, navigation and media. Unused keys are KC_NO, as in the
    // old layout, so they do not fall through to the letters of the base layer.
    [_LOWER] = LAYOUT_ortho_5x12(
        KC_F1,   KC_F2,   KC_F3,   KC_F4,   KC_F5,   KC_F6,   KC_F7,   KC_F8,   KC_F9,   KC_F10,  KC_F11,  KC_F12,
        KC_TAB,  XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, KC_GRV,  KC_LBRC, KC_RBRC, KC_BSLS, KC_DEL,
        KC_DEL,  XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, KC_INS,
        KC_LSFT, KC_MPLY, KC_VOLU, KC_VOLD, KC_MPRV, KC_MNXT, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, KC_ENT,
        KC_LCTL, KC_CAPS, KC_LGUI, KC_LALT, _______, _______, KC_SPC,  _______, KC_PSCR, KC_PGUP, KC_PGDN, KC_END
    ),

    // Raise: digits, function keys, punctuation.
    [_RAISE] = LAYOUT_ortho_5x12(
        KC_GRV,  KC_1,    KC_2,    KC_3,    KC_4,    KC_5,    KC_6,    KC_7,    KC_8,    KC_9,    KC_0,    KC_BSPC,
        KC_GRV,  KC_1,    KC_2,    KC_3,    KC_4,    KC_5,    KC_6,    KC_7,    KC_8,    KC_9,    KC_0,    KC_DEL,
        KC_DEL,  KC_F1,   KC_F2,   KC_F3,   KC_F4,   KC_F5,   KC_F6,   KC_MINS, KC_EQL,  KC_LBRC, KC_RBRC, KC_BSLS,
        _______, KC_F7,   KC_F8,   KC_F9,   KC_F10,  KC_F11,  KC_F12,  KC_NUHS, KC_NUBS, KC_PGUP, KC_PGDN, _______,
        _______, _______, _______, _______, _______, _______, _______, _______, KC_MNXT, KC_VOLD, KC_VOLU, KC_MPLY
    ),

    // Adjust (both layer keys): underglow, bootloader, debug. The audio keys of the
    // old layout were dropped.
    [_ADJUST] = LAYOUT_ortho_5x12(
        UG_TOGG, UG_PREV, UG_NEXT, UG_HUED, UG_HUEU, UG_SATD, UG_SATU, UG_VALD, UG_VALU, UG_SPDD, UG_SPDU, KC_F12,
        _______, QK_BOOT, DB_TOGG, _______, _______, _______, _______, _______, _______, _______, _______, KC_DEL,
        _______, _______, _______, _______, _______, _______, _______, _______, _______, _______, _______, _______,
        _______, _______, _______, _______, _______, _______, _______, _______, _______, _______, _______, _______,
        _______, _______, _______, _______, _______, _______, _______, _______, _______, _______, _______, _______
    ),
};

layer_state_t layer_state_set_user(layer_state_t state) {
    return update_tri_layer_state(state, _LOWER, _RAISE, _ADJUST);
}
