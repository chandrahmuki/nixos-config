#include QMK_KEYBOARD_H

enum layers { _QWERTY, _LOWER, _RAISE, _ADJUST, _FRENCH };

// French accents on top of the system layout us(altgr-intl) (kb_variant in the
// Hyprland config). Each key sends the AltGr sequence of that layout; a held
// Shift gives the capital letter.
enum custom_keycodes {
    FR_AGRV = SAFE_RANGE, // à
    FR_EGRV,              // è
    FR_EACU,              // é
    FR_ECIR,              // ê
    FR_EDIA,              // ë
    FR_ACIR,              // â
    FR_ICIR,              // î
    FR_IDIA,              // ï
    FR_OCIR,              // ô
    FR_UGRV,              // ù
    FR_UCIR,              // û
    FR_YDIA,              // ÿ
    FR_CCED,              // ç
    FR_OE,                // œ
    FR_LAQ,               // «
    FR_RAQ,               // »
    FR_EURO,              // €
};

// The two layer keys of the bottom row, which reads (physical order):
//   [ ] Ctrl Alt Super LOWER Space Space RAISE / Left Down Right
// LOWER (left of the space bar) turns on layer 1: F1-F12, navigation, media.
// RAISE (right of the space bar) turns on layer 2: digits, "-" and "=", F-keys.
// Holding both gives the Adjust layer. This is what the old firmware did; it was
// read from its machine code (backup/old-firmware-20261002.bin).
#define LOWER_KEY MO(_LOWER)
#define RAISE_KEY MO(_RAISE)

// Tap for "/", hold for the French accent layer.
#define FRENCH_KEY LT(_FRENCH, KC_SLSH)

// Home row mods: tap for the letter, hold for the modifier. Super on the pinkies,
// then Alt, Ctrl, Shift towards the index fingers, mirrored on the right hand.
// Alt is the left Alt on both hands (the right Alt would be AltGr).
#define HM_A    GUI_T(KC_A)
#define HM_S    ALT_T(KC_S)
#define HM_D    CTL_T(KC_D)
#define HM_F    SFT_T(KC_F)
#define HM_J    SFT_T(KC_J)
#define HM_K    CTL_T(KC_K)
#define HM_L    ALT_T(KC_L)
#define HM_SCLN GUI_T(KC_SCLN)

// Chordal Hold: a home row mod only becomes a modifier when the other key is on the
// OTHER hand. For a shortcut such as Super+S, hold the Super of the opposite hand
// (";" for a left-hand key, "A" for a right-hand key), or use the Super key of the
// bottom row, which is a plain key.
const char chordal_hold_layout[MATRIX_ROWS][MATRIX_COLS] PROGMEM = LAYOUT_ortho_5x12(
    'L', 'L', 'L', 'L', 'L', 'L', 'R', 'R', 'R', 'R', 'R', 'R',
    'L', 'L', 'L', 'L', 'L', 'L', 'R', 'R', 'R', 'R', 'R', 'R',
    'L', 'L', 'L', 'L', 'L', 'L', 'R', 'R', 'R', 'R', 'R', 'R',
    'L', 'L', 'L', 'L', 'L', 'L', 'R', 'R', 'R', 'R', 'R', 'R',
    'L', 'L', 'L', 'L', 'L', 'L', 'R', 'R', 'R', 'R', 'R', 'R'
);

// Rows are in the physical order of LAYOUT_ortho_5x12. The bottom row of the
// matrix is interleaved (8,0 8,1 8,2 9,3 9,4 9,5 9,0 9,1 9,2 8,3 8,4 8,5), so it
// must never be read as "left half then right half".
const uint16_t PROGMEM keymaps[][MATRIX_ROWS][MATRIX_COLS] = {
    // Base. Copy of the layout read from the keyboard on 2026-10-02
    // (qmk/backup/preonic-rev3-original-layout.txt).
    [_QWERTY] = LAYOUT_ortho_5x12(
        KC_GRV,  KC_1,    KC_2,    KC_3,    KC_4,    KC_5,    KC_6,    KC_7,    KC_8,    KC_9,    KC_0,    KC_DEL,
        KC_TAB,  KC_Q,    KC_W,    KC_E,    KC_R,    KC_T,    KC_Y,    KC_U,    KC_I,    KC_O,    KC_P,    KC_BSPC,
        KC_ESC,  HM_A,    HM_S,    HM_D,    HM_F,    KC_G,    KC_H,    HM_J,    HM_K,    HM_L,    HM_SCLN, KC_QUOT,
        KC_LSFT, KC_Z,    KC_X,    KC_C,    KC_V,    KC_B,    KC_N,    KC_M,    KC_COMM, KC_DOT,  KC_UP,   SC_SENT,
        UG_TOGG, KC_LCTL, KC_LALT, KC_LGUI, LOWER_KEY, KC_SPC, KC_SPC,  RAISE_KEY, FRENCH_KEY, KC_LEFT, KC_DOWN, KC_RGHT
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

    // French accents, while "/" is held. Vowels keep their own positions where
    // possible; everything else falls through to the base layer.
    [_FRENCH] = LAYOUT_ortho_5x12(
        _______, _______, _______, _______, FR_EURO, _______, _______, _______, _______, _______, _______, _______,
        _______, FR_ACIR, FR_EGRV, FR_EACU, FR_ECIR, FR_EDIA, FR_YDIA, FR_UGRV, FR_ICIR, FR_OCIR, FR_OE,   _______,
        _______, FR_AGRV, _______, _______, _______, _______, _______, FR_UCIR, FR_IDIA, _______, _______, _______,
        _______, _______, _______, FR_CCED, _______, _______, _______, _______, FR_LAQ,  FR_RAQ,  _______, _______,
        _______, _______, _______, _______, _______, _______, _______, _______, _______, _______, _______, _______
    ),
};

layer_state_t layer_state_set_user(layer_state_t state) {
    return update_tri_layer_state(state, _LOWER, _RAISE, _ADJUST);
}

// Chordal Hold would read "/" plus a right-hand key as two taps (same hand), which
// would make the accents of the right hand impossible. The accent key always holds.
bool get_chordal_hold(uint16_t tap_hold_keycode, keyrecord_t *tap_hold_record,
                      uint16_t other_keycode, keyrecord_t *other_record) {
    if (tap_hold_keycode == FRENCH_KEY) {
        return true;
    }
    return get_chordal_hold_default(tap_hold_record, other_record);
}

// A dead key followed by a letter (dead == 0: the letter is typed with AltGr).
static void send_accent(uint16_t dead, uint16_t key, bool shift) {
    if (dead) {
        tap_code16(RALT(dead));
        tap_code16(shift ? S(key) : key);
    } else {
        tap_code16(shift ? RALT(S(key)) : RALT(key));
    }
}

bool process_record_user(uint16_t keycode, keyrecord_t *record) {
    if (keycode < SAFE_RANGE || !record->event.pressed) {
        return true;
    }

    const uint8_t saved_mods = get_mods();
    const bool    shift      = (saved_mods | get_weak_mods()) & MOD_MASK_SHIFT;
    clear_mods();
    clear_weak_mods();

    switch (keycode) {
        case FR_AGRV: send_accent(KC_GRV, KC_A, shift); break;
        case FR_EGRV: send_accent(KC_GRV, KC_E, shift); break;
        case FR_UGRV: send_accent(KC_GRV, KC_U, shift); break;
        case FR_ACIR: send_accent(KC_6, KC_A, shift); break;
        case FR_ECIR: send_accent(KC_6, KC_E, shift); break;
        case FR_ICIR: send_accent(KC_6, KC_I, shift); break;
        case FR_OCIR: send_accent(KC_6, KC_O, shift); break;
        case FR_UCIR: send_accent(KC_6, KC_U, shift); break;
        case FR_IDIA: send_accent(S(KC_QUOT), KC_I, shift); break; // dead diaeresis: AltGr+Shift+'
        case FR_YDIA: send_accent(S(KC_QUOT), KC_Y, shift); break;
        case FR_EACU: send_accent(0, KC_E, shift); break;
        case FR_EDIA: send_accent(0, KC_R, shift); break; // ë is on AltGr+R in altgr-intl
        case FR_CCED: send_accent(0, KC_COMM, false); break;
        case FR_OE:   send_accent(0, KC_X, shift); break;
        case FR_LAQ:  send_accent(0, KC_LBRC, false); break;
        case FR_RAQ:  send_accent(0, KC_RBRC, false); break;
        case FR_EURO: send_accent(0, KC_5, false); break;
    }

    set_mods(saved_mods);
    return false;
}
