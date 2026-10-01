import QtQuick

Item {
    id: clockControl
    required property var shell
    width: 76
    height: 24
    signal openRequested()
    signal closeRequested()

    Timer {
        id: openTimer
        interval: 180
        repeat: false
        onTriggered: {
            if (clockHover.hovered)
                clockControl.openRequested();
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
        id: clockHover
        onHoveredChanged: {
            if (hovered)
                clockControl.schedulePanelOpen();
            else
                clockControl.schedulePanelClose();
        }
    }

    Row {
        anchors.centerIn: parent
        spacing: 2

        PillIcon {
            shell: clockControl.shell
            hovered: clockHover.hovered
            glyph: "󰥔"
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: Qt.formatTime(clockControl.shell.now, "HH:mm")
            color: clockControl.shell.retroCyan
            font.bold: true
            font.pixelSize: 15
            font.family: clockControl.shell.pillFont
        }
    }
}
