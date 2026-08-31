import QtQuick

Item {
    id: volumeControl
    required property var shell
    width: volumeHover.hovered ? 92 : 24
    height: 24

    Behavior on width {
        NumberAnimation { duration: 160; easing.type: Easing.OutCubic }
    }

    HoverHandler { id: volumeHover }

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: volumeHover.hovered ? "#202020" : "transparent"
    }

    Text {
        anchors.left: parent.left
        anchors.leftMargin: 4
        anchors.verticalCenter: parent.verticalCenter
        text: volumeControl.shell.systemMuted || volumeControl.shell.systemVolume === 0 ? "" : ""
        color: volumeControl.shell.pillForeground
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 19
    }

    MouseArea {
        visible: volumeHover.hovered
        anchors.left: parent.left
        anchors.leftMargin: 27
        anchors.right: parent.right
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        height: parent.height
        cursorShape: Qt.PointingHandCursor
        onClicked: function(mouse) {
            volumeControl.shell.setSystemVolume(mouse.x / width);
        }
        onPositionChanged: function(mouse) {
            if (pressed)
                volumeControl.shell.setSystemVolume(mouse.x / width);
        }
    }

    Rectangle {
        visible: volumeHover.hovered
        anchors.left: parent.left
        anchors.leftMargin: 31
        anchors.right: parent.right
        anchors.rightMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        height: 4
        radius: 2
        color: "#555555"
    }

    Rectangle {
        visible: volumeHover.hovered
        anchors.left: parent.left
        anchors.leftMargin: 31
        anchors.verticalCenter: parent.verticalCenter
        width: Math.max(0, (parent.width - 41) * volumeControl.shell.systemVolume)
        height: 4
        radius: 2
        color: volumeControl.shell.pillForeground
    }
}
