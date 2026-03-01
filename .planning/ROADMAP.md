# Roadmap: Milestone 2 - Fix Noctalia Media Mixer [COMPLETED]

## Phase 1: Research & Architecture Analysis [COMPLETED]
- [x] Understand how `MediaService.qml` handles MPRIS.
- [x] Understand PipeWire `appStreams` object structure in Quickshell.
- [x] Investigate how MPV identifies itself in PipeWire vs MPRIS.
- [x] Investigate how Brave/Chromium identifies itself in PipeWire vs MPRIS.

## Phase 2: Design Robust Matching Logic [COMPLETED]
- [x] Define precise `includes` or regex matching logic for `identity`, `desktopEntry`, `name`, and `busName` for MPRIS.
- [x] Define fallback behavior (e.g., when no MPRIS player is found for a stream, disable play/pause button and artwork).

## Phase 3: Implementation & Testing [COMPLETED]
- [x] Rewrite the QML logic inside `DesktopMediaMixer.qml`.
- [x] Test with Brave playing audio.
- [x] Test with MPV playing audio.
- [x] Ensure switching between them correctly updates artwork, title, and playback controls.

## Final Review & Archiving [COMPLETED]
- [x] Verify logs for QML errors.
- [x] Fix MPV MPRIS wrapper in NixOS configuration.
