import QtQuick
import Quickshell.Io

// The active network connection (nmcli), its addresses and the live traffic rates
// read from /sys. The shell exposes it as `shell.network`.
Item {
    id: network

    property string type: ""
    property string connectionName: ""
    property string device: ""
    property string address: "—"
    property string gateway: "—"
    property string dns: "—"
    property real downloadRate: 0
    property real uploadRate: 0
    property var downloadHistory: Array(18).fill(0)
    property var uploadHistory: Array(18).fill(0)

    function rateLabel(bytesPerSecond: real): string {
        if (bytesPerSecond >= 1000000)
            return (bytesPerSecond / 1000000).toFixed(1) + " MB/s";
        if (bytesPerSecond >= 1000)
            return (bytesPerSecond / 1000).toFixed(1) + " KB/s";
        return Math.round(bytesPerSecond) + " B/s";
    }

    Process {
        id: statusProcess
        command: ["bash", "-c",
            "nmcli -t -f DEVICE,TYPE,STATE,CONNECTION device | grep -E '^[^:]+:(wifi|ethernet):connected:' | head -n 1"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                const fields = data.split(":");
                network.device = fields[0] || "";
                network.type = fields[1] || "";
                network.connectionName = fields.slice(3).join(":") || "";
                if (!detailsProcess.running && network.device.length > 0)
                    detailsProcess.running = true;
            }
        }
    }

    Process {
        id: detailsProcess
        property int fieldIndex: 0
        command: ["nmcli", "-g", "IP4.ADDRESS,IP4.GATEWAY,IP4.DNS", "device", "show", network.device]
        running: false
        onRunningChanged: if (running) fieldIndex = 0
        stdout: SplitParser {
            onRead: data => {
                const value = data.trim().replace(/\/\d+$/, "");
                if (detailsProcess.fieldIndex === 0)
                    network.address = value || "—";
                else if (detailsProcess.fieldIndex === 1)
                    network.gateway = value || "—";
                else if (detailsProcess.fieldIndex === 2)
                    network.dns = value || "—";
                detailsProcess.fieldIndex++;
            }
        }
    }

    Process {
        id: trafficProcess
        property int fieldIndex: 0
        property real sampledRx: 0
        property real lastRx: -1
        property real lastTx: -1
        command: ["cat", "/sys/class/net/" + network.device + "/statistics/rx_bytes",
            "/sys/class/net/" + network.device + "/statistics/tx_bytes"]
        running: false
        onRunningChanged: if (running) fieldIndex = 0
        stdout: SplitParser {
            onRead: data => {
                const value = Number(data.trim()) || 0;
                if (trafficProcess.fieldIndex === 0)
                    trafficProcess.sampledRx = value;
                else {
                    const down = trafficProcess.lastRx < 0 ? 0
                        : Math.max(0, trafficProcess.sampledRx - trafficProcess.lastRx);
                    const up = trafficProcess.lastTx < 0 ? 0
                        : Math.max(0, value - trafficProcess.lastTx);
                    network.downloadRate = down;
                    network.uploadRate = up;
                    network.downloadHistory = network.downloadHistory.slice(1).concat([Math.min(1, down / 12500000)]);
                    network.uploadHistory = network.uploadHistory.slice(1).concat([Math.min(1, up / 2500000)]);
                    trafficProcess.lastRx = trafficProcess.sampledRx;
                    trafficProcess.lastTx = value;
                }
                trafficProcess.fieldIndex++;
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

    Timer {
        interval: 1000
        running: network.device.length > 0
        repeat: true
        onTriggered: {
            if (!trafficProcess.running)
                trafficProcess.running = true;
        }
    }
}
