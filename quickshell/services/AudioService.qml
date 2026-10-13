import QtQuick
import Quickshell.Io

// The default audio output (wpctl): its volume and mute state, refreshed every
// two seconds, and the setter. The shell exposes it as `shell.audio`.
Item {
    id: audio

    property real volume: 0
    property bool muted: false

    Process {
        id: statusProcess
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                const match = data.match(/Volume:\s+([0-9.]+)/);
                if (match)
                    audio.volume = Math.max(0, Math.min(1, Number(match[1])));
                audio.muted = data.includes("MUTED");
            }
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            if (!statusProcess.running)
                statusProcess.running = true;
        }
    }

    Process {
        id: setProcess
        property real requestedVolume: 0
        command: ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@",
            Math.round(requestedVolume * 100) + "%"]
        running: false
    }

    function setVolume(value: real): void {
        volume = Math.max(0, Math.min(1, value));
        muted = false;
        setProcess.requestedVolume = volume;
        setProcess.running = true;
    }
}
