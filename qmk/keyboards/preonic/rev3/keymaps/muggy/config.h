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
