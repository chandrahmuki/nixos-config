import QtQuick

Item {
    id: clockControl
    required property var shell
    width: 54
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

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: clockHover.hovered ? "#202020" : "transparent"
    }

    Text {
        anchors.centerIn: parent
        text: Qt.formatTime(clockControl.shell.now, "HH:mm")
        color: clockControl.shell.pillForeground
        font.bold: true
        font.pixelSize: 17
        font.family: clockControl.shell.pillFont
    }
}
