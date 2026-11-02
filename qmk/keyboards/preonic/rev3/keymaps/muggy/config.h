#pragma once

// Longer than the bounce measured on the "e" key (24 ms).
#define DEBOUNCE 30

// Only the "/" accent key is a tap-hold key. A hold longer than the tapping term is a hold.
#define TAPPING_TERM 200
// With the other key on the opposite hand, hold as soon as it is pressed and released.
#define PERMISSIVE_HOLD
// Same-hand chords settle as taps.
#define CHORDAL_HOLD
// While typing fast, "/" right after another letter stays a tap.
#define FLOW_TAP_TERM 150

// Dead-key sequences need the host to see each key in its own report.
#define TAP_CODE_DELAY 10

// Retro tapping on "/", see get_retro_tapping() in keymap.c.
#define RETRO_TAPPING_PER_KEY
