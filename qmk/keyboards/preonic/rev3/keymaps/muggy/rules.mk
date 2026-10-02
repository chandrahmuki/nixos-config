# VIA is off on purpose: this keymap is the single source of truth, versioned
# in git. The layout read from the old VIA firmware is saved in qmk/backup/.

# Eager on press (no added latency), deferred on release: absorbs the contact
# bounce measured on the "e" switch (16-24 ms between presses, 8 ms release gap).
DEBOUNCE_TYPE = asym_eager_defer_pk

LTO_ENABLE = yes
