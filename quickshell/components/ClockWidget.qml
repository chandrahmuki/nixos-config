import QtQuick

Item {
    id: clockControl
    required property var shell
    width: clockText.implicitWidth + 16
    height: 44
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
        anchors.margins: 2
        radius: 6
        color: clockHover.hovered ? clockControl.shell.theme.surfaceHover : "transparent"
    }

    // Just the time: the clock icon next to it carried no information.
    Text {
        id: clockText
        anchors.centerIn: parent
        text: Qt.formatTime(clockControl.shell.now, "HH:mm")
        color: clockControl.shell.theme.pillForeground
        font.weight: Font.DemiBold
        font.pixelSize: 22
        font.family: clockControl.shell.theme.pillFont
    }
}
