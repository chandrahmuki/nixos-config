import QtQuick
import Quickshell.Io
import Quickshell.Services.Mpris

// The MPRIS player shown in the music island: which player is current, how its volume
// is read and set (PipeWire for the players whose MPRIS volume does nothing), and the
// four CAVA bars. The shell exposes it as `shell.music`.
Item {
    id: music

    property var player: null
    // Some players expose an MPRIS volume property without applying it to
    // their actual PipeWire stream. Route those known players to PipeWire.
    property real browserVolume: 1
    readonly property string streamMatch: {
        if (!player)
            return "";
        const dbusName = player.dbusName.toLowerCase();
        const desktopEntry = player.desktopEntry.toLowerCase();
        if (dbusName.indexOf("chromium") >= 0 || desktopEntry.indexOf("helium") >= 0)
            return "helium";
        return "";
    }
    readonly property bool usesPipeWireVolume: streamMatch.length > 0
    readonly property real volume: usesPipeWireVolume
        ? browserVolume
        : player && player.volumeSupported ? player.volume : 0
    property var cavaLevels: [0, 0, 0, 0]

    function setVolume(value: real): void {
        if (!player)
            return;

        const level = Math.max(0, Math.min(1, value));
        if (usesPipeWireVolume) {
            browserVolume = level;
            browserVolumeProcess.requestedVolume = level;
            browserVolumeProcess.streamMatch = streamMatch;
            browserVolumeProcess.running = true;
            return;
        }

        if (player.volumeSupported)
            player.volume = level;
    }

    Process {
        id: browserVolumeProcess
        property real requestedVolume: 1
        property string streamMatch: ""
        // Stream IDs change after restarts. Match only the active playback
        // stream for the current player, never an input/monitor stream.
        command: ["bash", "-c", "wpctl status | awk -v needle=\"$2\" '/Streams:/ { streams = 1; next } /Video/ { streams = 0 } streams && /^[[:space:]]*[0-9]+\\. PipeWire ALSA/ && index(tolower($0), needle) { id = $1; sub(/\\.$/, \"\", id); print id }' | while read -r stream; do wpctl set-volume $stream $1; done", "--", requestedVolume.toFixed(3), streamMatch]
        running: false
    }

    function selectFallback(): void {
        player = Mpris.players.values.find(function(player) {
            return player.isPlaying;
        }) || null;
    }

    Process {
        id: cavaProcess
        // CAVA emits one semicolon-delimited frame per line. Keeping it here
        // avoids a second daemon and makes the pill own its visualizer.
        command: ["bash", "-c", "printf '%s\\n' '[general]' 'bars = 4' 'framerate = 15' 'autosens = 1' '[input]' 'method = pulse' 'source = auto' '[output]' 'method = raw' 'raw_target = /dev/stdout' 'data_format = ascii' 'ascii_max_range = 100' 'bar_delimiter = 59' 'frame_delimiter = 10' | cava -p /dev/stdin"]
        // No music means no visualizer process or frame parsing.
        running: music.player && music.player.isPlaying

        stdout: SplitParser {
            onRead: data => {
                var frame = data.trim().split(";").filter(function(value) {
                    return value.length > 0;
                });
                if (frame.length !== 4)
                    return;

                music.cavaLevels = frame.map(function(value) {
                    return Math.max(0, Math.min(100, Number(value) || 0));
                });
            }
        }
    }

    Instantiator {
        model: Mpris.players

        delegate: Connections {
            required property var modelData
            target: modelData

            Component.onCompleted: {
                if (modelData.isPlaying)
                    music.player = modelData;
            }

            function onIsPlayingChanged(): void {
                if (modelData.isPlaying)
                    music.player = modelData;
                else if (music.player === modelData)
                    music.selectFallback();
            }
        }
    }
}
