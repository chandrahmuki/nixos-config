import QtQuick

Item {
    id: audioControl
    required property var shell
    signal openRequested()
    signal closeRequested()
    width: 40
    height: 44

    Timer {
        id: openTimer
        interval: 180
        repeat: false
        onTriggered: {
            if (audioHover.hovered)
                audioControl.openRequested();
        }
    }

    function schedulePanelOpen(): void { openTimer.restart(); }
    function schedulePanelClose(): void {
        openTimer.stop();
        closeRequested();
    }

    HoverHandler {
        id: audioHover
        onHoveredChanged: hovered ? audioControl.schedulePanelOpen() : audioControl.schedulePanelClose()
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: 2
        radius: 6
        color: audioHover.hovered ? audioControl.shell.theme.surfaceHover : "transparent"
    }

    PixelIcon {
        anchors.centerIn: parent
        name: audioControl.shell.audio.muted || audioControl.shell.audio.volume <= 0.01
            ? "volume-muted" : audioControl.shell.audio.volume < 0.5 ? "volume-low" : "volume"
        color: audioControl.shell.audio.muted
            ? audioControl.shell.theme.retroCoral : audioControl.shell.theme.pillForeground
    }
}
