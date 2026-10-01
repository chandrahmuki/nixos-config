import QtQuick

Item {
    id: networkControl
    required property var shell
    // Hyprland.monitorFor() can be null for one frame during hot reload.
    property var monitor: null
    signal openRequested()
    signal closeRequested()
    width: 22
    height: 24

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

    PillIcon {
        anchors.centerIn: parent
        shell: networkControl.shell
        hovered: networkHover.hovered
        glyph: networkControl.shell.networkType === "ethernet" ? "󰈀"
            : networkControl.shell.networkType === "wifi" ? "󰖩" : "󰤭"
        iconColor: networkControl.shell.networkConnectionName.length > 0
            ? networkControl.shell.retroCyan : networkControl.shell.pillMuted
    }
}
