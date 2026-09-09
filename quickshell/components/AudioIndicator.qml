import QtQuick

Item {
    id: audioControl
    required property var shell
    signal openRequested()
    signal closeRequested()
    width: 22
    height: 24

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
        radius: 4
        color: audioHover.hovered ? "#242424" : "transparent"
    }

    Text {
        anchors.centerIn: parent
        text: audioControl.shell.systemMuted || audioControl.shell.systemVolume <= 0.01
            ? "󰖁" : audioControl.shell.systemVolume < 0.5 ? "󰖀" : "󰕾"
        color: audioControl.shell.systemMuted ? audioControl.shell.retroCoral : audioControl.shell.retroAmber
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 18
    }
}
