import QtQuick

Item {
    id: networkControl
    required property var shell
    // Hyprland.monitorFor() can be null for one frame during hot reload.
    property var monitor: null
    signal openRequested()
    signal closeRequested()
    width: 40
    height: 44
    readonly property bool connected: shell.network.connectionName.length > 0

    Timer {
        id: openTimer
        interval: 180
        repeat: false
        onTriggered: {
            if (networkHover.hovered)
                networkControl.openRequested();
        }
    }

    function schedulePanelOpen(): void {
        openTimer.restart();
    }

    function schedulePanelClose(): void {
        openTimer.stop();
        closeRequested();
    }

    HoverHandler {
        id: networkHover
        onHoveredChanged: {
            if (hovered)
                networkControl.schedulePanelOpen();
            else
                networkControl.schedulePanelClose();
        }
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: 2
        radius: 6
        color: networkHover.hovered ? networkControl.shell.theme.surfaceHover : "transparent"
    }

    PixelIcon {
        anchors.centerIn: parent
        name: networkControl.shell.network.type === "ethernet" ? "ethernet"
            : networkControl.shell.network.type === "wifi" ? "wifi" : "wifi-off"
        color: networkControl.connected
            ? networkControl.shell.theme.pillForeground : networkControl.shell.theme.pillSecondary
    }

    // Live connection marker.
    Rectangle {
        visible: networkControl.connected
        x: parent.width - width - 5
        y: 5
        width: 6
        height: 6
        color: networkControl.shell.theme.retroCyan
    }
}
