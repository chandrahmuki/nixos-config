import QtQuick

Item {
    id: volumeControl
    required property var shell
    // A meter belongs in the compact pill more naturally than a speaker
    // glyph. Keep its footprint fixed so changing the volume never makes the
    // whole bar jump sideways.
    width: 30
    height: 24

    readonly property real level: shell.systemMuted ? 0 : shell.systemVolume
    property bool volumeHovered: false

    Row {
        anchors.centerIn: parent
        spacing: 2

        Repeater {
            model: 5
            delegate: Rectangle {
                required property int index
                readonly property real threshold: (index + 1) / 5
                width: 4
                height: 6 + index * 3
                anchors.verticalCenter: parent.verticalCenter
                radius: 1
                color: volumeControl.level >= threshold
                    ? volumeControl.shell.retroAmber : volumeControl.shell.pillMuted
                opacity: volumeControl.volumeHovered || volumeControl.level >= threshold
                    ? 1 : 0.65

                Behavior on color { ColorAnimation { duration: 100 } }
            }
        }
    }

    MouseArea {
        id: volumeMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onContainsMouseChanged: volumeControl.volumeHovered = containsMouse

        function setVolumeAt(x: real): void {
            volumeControl.shell.setSystemVolume(Math.max(0, Math.min(1, x / width)));
        }

        onClicked: function(mouse) {
            setVolumeAt(mouse.x);
        }
        onPositionChanged: function(mouse) {
            if (pressed)
                setVolumeAt(mouse.x);
        }
    }
}
