import QtQuick

Rectangle {
    id: musicIsland
    required property var shell
    readonly property bool expanded: musicHoverArea.containsMouse
    visible: !!musicIsland.shell.activePlayer
    width: expanded ? musicIsland.shell.musicExpandedWidth : 38
    height: 26
    radius: height / 2
    color: "transparent"
    border.width: 0
    clip: true

    Behavior on width {
        NumberAnimation { duration: 190; easing.type: Easing.OutCubic }
    }

    MouseArea {
        id: musicHoverArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
    }

    Row {
        visible: !musicIsland.expanded
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        spacing: 3

        Repeater {
            model: 4
            delegate: Rectangle {
                required property int index
                width: 3
                height: musicIsland.shell.activePlayer && musicIsland.shell.activePlayer.isPlaying
                    ? 3 + musicIsland.shell.cavaLevels[index] * 0.14 : 3
                radius: 1.5
                color: musicIsland.shell.pillForeground
                Behavior on height {
                    NumberAnimation { duration: 45; easing.type: Easing.OutQuad }
                }
            }
        }
    }

    Item {
        id: musicTitleViewport
        visible: musicIsland.expanded
        anchors.left: parent.left
        anchors.leftMargin: 14
        anchors.right: parent.right
        anchors.rightMargin: 170
        anchors.verticalCenter: parent.verticalCenter
        height: parent.height
        clip: true

        Text {
            id: musicTitle
            anchors.verticalCenter: parent.verticalCenter
            text: musicIsland.shell.activePlayer
                ? musicIsland.shell.activePlayer.trackTitle
                    + (musicIsland.shell.activePlayer.trackArtist
                        ? " — " + musicIsland.shell.activePlayer.trackArtist : "")
                : ""
            color: musicIsland.shell.pillForeground
            font.pixelSize: 12
            font.family: musicIsland.shell.pillFont
            x: 0

            SequentialAnimation on x {
                running: musicIsland.expanded
                    && musicTitle.contentWidth > musicTitleViewport.width
                loops: Animation.Infinite
                PauseAnimation { duration: 900 }
                NumberAnimation {
                    to: -(musicTitle.contentWidth - musicTitleViewport.width)
                    duration: Math.max(1800,
                        (musicTitle.contentWidth - musicTitleViewport.width) * 24)
                }
                PauseAnimation { duration: 900 }
                NumberAnimation { to: 0; duration: 260 }
            }
        }
    }

    Row {
        id: musicControls
        visible: musicIsland.expanded
        anchors.right: parent.right
        anchors.rightMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        spacing: 5

        Rectangle {
            width: 22
            height: 22
            radius: 11
            color: musicPrevious.pressed ? "#383838" : "transparent"
            opacity: musicIsland.shell.activePlayer && musicIsland.shell.activePlayer.canGoPrevious ? 1 : 0.35
            Text {
                anchors.centerIn: parent
                text: "‹"
                color: musicIsland.shell.pillForeground
                font.pixelSize: 18
            }
            MouseArea {
                id: musicPrevious
                anchors.fill: parent
                enabled: musicIsland.shell.activePlayer && musicIsland.shell.activePlayer.canGoPrevious
                onClicked: musicIsland.shell.activePlayer.previous()
            }
        }

        Rectangle {
            width: 24
            height: 24
            radius: 12
            color: musicToggle.pressed ? "#404040" : "#2a2a2a"
            opacity: musicIsland.shell.activePlayer && musicIsland.shell.activePlayer.canTogglePlaying ? 1 : 0.35
            Text {
                anchors.centerIn: parent
                text: musicIsland.shell.activePlayer && musicIsland.shell.activePlayer.isPlaying ? "Ⅱ" : "▶"
                color: musicIsland.shell.pillForeground
                font.pixelSize: 11
            }
            MouseArea {
                id: musicToggle
                anchors.fill: parent
                enabled: musicIsland.shell.activePlayer && musicIsland.shell.activePlayer.canTogglePlaying
                onClicked: musicIsland.shell.activePlayer.togglePlaying()
            }
        }

        Rectangle {
            width: 22
            height: 22
            radius: 11
            color: musicNext.pressed ? "#383838" : "transparent"
            opacity: musicIsland.shell.activePlayer && musicIsland.shell.activePlayer.canGoNext ? 1 : 0.35
            Text {
                anchors.centerIn: parent
                text: "›"
                color: musicIsland.shell.pillForeground
                font.pixelSize: 18
            }
            MouseArea {
                id: musicNext
                anchors.fill: parent
                enabled: musicIsland.shell.activePlayer && musicIsland.shell.activePlayer.canGoNext
                onClicked: musicIsland.shell.activePlayer.next()
            }
        }

        Item {
            visible: musicIsland.shell.activePlayer && musicIsland.shell.activePlayer.volumeSupported
            width: visible ? 64 : 0
            height: 22

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width
                height: 4
                radius: 2
                color: "#3c3c3c"
            }
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width * Math.max(0, Math.min(1,
                    musicIsland.shell.activePlayerVolume))
                height: 4
                radius: 2
                color: musicIsland.shell.pillForeground
            }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onPressed: function(mouse) {
                    musicIsland.shell.setActivePlayerVolume(mouse.x / width);
                }
                onPositionChanged: function(mouse) {
                    if (pressed)
                        musicIsland.shell.setActivePlayerVolume(mouse.x / width);
                }
                onClicked: function(mouse) {
                    musicIsland.shell.setActivePlayerVolume(mouse.x / width);
                }
            }
        }
    }
}
