# Requirements: Media Mixer Plugin

## User Story
As a user, when I open the Desktop Media Mixer widget in Noctalia and select a specific audio stream (e.g., `mpv` or `Brave`), the widget MUST display the metadata (artwork, title, artist) AND control the playback (play/pause) exclusively for that selected stream. It should NOT default to another playing stream if the selected one doesn't match properly.

## Technical Constraints
1. **PipeWire (`AudioService.appStreams`)**: The list of audio streams currently outputting sound.
2. **MPRIS (`Mpris.players` or `MediaService`)**: The list of players that expose media controls.
3. The bridge between PipeWire streams and MPRIS players must be robust. It must handle `mpv` and browsers (`Brave`) uniquely.
4. **No global service conflicts**: The widget must maintain its own state or use `MediaService` in a way that doesn't get overwritten by the background 2-second monitor loop.

## Expected Behavior
- When `Master Volume` (Index -1) is selected: Use `MediaService.currentPlayer` (global default).
- When `Stream X` is selected: Find the exact MPRIS player matching `Stream X`.
- If a match is found: Show its metadata and bind the play/pause button to it.
- If NO match is found: Show "No Media Playing", disable artwork, and disable the play/pause button. Do NOT show Brave's metadata if MPV is selected but not matched.
