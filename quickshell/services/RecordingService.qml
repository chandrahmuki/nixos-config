import QtQuick
import Quickshell.Io

// The state of muggy-screen-record (aspects/screen-recording.nix): whether the recorder
// unit is running, on which monitor, since when, and how big the output file is. Read
// once per second from the unit and the state file the script writes. The shell exposes
// it as `shell.recording`.
Item {
    id: recording

    property bool active: false
    property string monitor: ""
    property string output: ""
    property real startedAt: 0
    property real bytes: 0
    property real elapsed: 0

    function pad(value: int): string {
        return value < 10 ? "0" + value : String(value);
    }

    readonly property string elapsedLabel: {
        const total = Math.max(0, Math.floor(recording.elapsed));
        const hours = Math.floor(total / 3600);
        const minutes = Math.floor((total % 3600) / 60);
        const seconds = total % 60;
        return (hours > 0 ? hours + ":" : "") + pad(minutes) + ":" + pad(seconds);
    }

    readonly property string sizeLabel: {
        if (recording.bytes >= 1000000000)
            return (recording.bytes / 1000000000).toFixed(1).replace(".", ",") + " Go";
        return Math.round(recording.bytes / 1000000) + " Mo";
    }

    Process {
        id: statusProcess
        command: ["bash", "-c",
            "d=\"$XDG_RUNTIME_DIR/muggy-screen-recorder\"; "
            + "if systemctl --user is-active --quiet muggy-screen-recorder.service && [ -f \"$d/current\" ]; then "
            + "o=$(sed -n 1p \"$d/current\"); m=$(sed -n 2p \"$d/current\"); "
            + "s=$(stat -c %Y \"$d/current\"); z=$(stat -c %s \"$o\" 2>/dev/null || echo 0); "
            + "echo \"rec|$s|$z|$m|$o\"; else echo idle; fi"]
        running: false
        stdout: SplitParser {
            onRead: data => {
                const fields = data.trim().split("|");
                if (fields[0] !== "rec") {
                    recording.active = false;
                    return;
                }
                recording.startedAt = Number(fields[1]);
                recording.bytes = Number(fields[2]);
                recording.monitor = fields[3] || "";
                recording.output = fields.slice(4).join("|");
                recording.elapsed = Date.now() / 1000 - recording.startedAt;
                recording.active = true;
            }
        }
    }

    Timer {
        interval: 1000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: {
            if (!statusProcess.running)
                statusProcess.running = true;
            if (recording.active)
                recording.elapsed = Date.now() / 1000 - recording.startedAt;
        }
    }
}
