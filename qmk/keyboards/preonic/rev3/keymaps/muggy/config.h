#pragma once

// Longer than the bounce measured on the "e" key (24 ms).
#define DEBOUNCE 30

// Home row mods. A hold longer than the tapping term is a modifier.
#define TAPPING_TERM 200
// With the other key on the opposite hand, hold as soon as it is pressed and released.
#define PERMISSIVE_HOLD
// Same-hand chords settle as taps, which stops rolled letters from becoming modifiers.
#define CHORDAL_HOLD
// While typing fast, a home row key right after another letter stays a letter.
#define FLOW_TAP_TERM 150

// Dead-key sequences need the host to see each key in its own report.
#define TAP_CODE_DELAY 10

// Per-key hold time, see get_tapping_term() in keymap.c.
#define TAPPING_TERM_PER_KEY

// Retro tapping on the home row keys and "/", see get_retro_tapping() in keymap.c. A
// lone Alt or Super is released through F18 so it does not open application menus.
#define RETRO_TAPPING_PER_KEY
#define DUMMY_MOD_NEUTRALIZER_KEYCODE KC_F18
