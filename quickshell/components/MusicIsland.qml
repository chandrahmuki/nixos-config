import QtQuick

Rectangle {
    id: musicPanel
    required property var shell
    property bool expanded: false
    // Fixed-size card that fades + pops in in place (opacity/scale off the
    // "expanded" flip), same technique as ChillPill-Shell's MediaPopup —
    // no geometry morph, so there's nothing for content to drift with and
    // nothing to steal the hover out from under the cursor mid-animation.
    visible: opacity > 0
    // Nested inside islandShape now (PillWindow) — that parent already sits
    // at the pill's y (or off-screen in strict fullscreen), so this is 0,
    // not a repeat of that offset.
    y: 0
    opacity: expanded ? 1 : 0
    scale: expanded ? 1 : 0.96
    transformOrigin: Item.Center
    radius: 14
    clip: true
    color: shell.pillBackground

    Behavior on opacity { NumberAnimation { duration: 180 } }
    Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

    function openPanel(): void {
        closeTimer.stop();
        expanded = true;
    }

    function scheduleClose(): void {
        closeTimer.restart();
    }

    Timer {
        id: closeTimer
        interval: 300
        repeat: false
        onTriggered: {
            if (!panelHover.hovered)
                musicPanel.expanded = false;
        }
    }

    HoverHandler {
        id: panelHover
        enabled: musicPanel.expanded
        onHoveredChanged: {
            if (hovered)
                closeTimer.stop();
            else
                musicPanel.scheduleClose();
        }
    }

    Item {
        id: cavaSlot
        anchors.top: parent.top
        anchors.topMargin: 15
        anchors.horizontalCenter: parent.horizontalCenter
        width: 82
        height: 30

        Row {
            anchors.centerIn: parent
            spacing: 7

            Repeater {
                model: 4
                delegate: Rectangle {
                    required property int index
                    width: 6
                    height: musicPanel.shell.activePlayer && musicPanel.shell.activePlayer.isPlaying
                        ? 6 + musicPanel.shell.cavaLevels[index] * 0.19 : 6
                    anchors.verticalCenter: parent.verticalCenter
                    radius: 3
                    color: musicPanel.shell.active
                    Behavior on height { NumberAnimation { duration: 45; easing.type: Easing.OutQuad } }
                }
            }
        }
    }

    Item {
        id: titleViewport
        anchors.top: cavaSlot.bottom
        anchors.topMargin: 10
        anchors.horizontalCenter: parent.horizontalCenter
        width: Math.min(parent.width - 80, 400)
        height: 23
        clip: true

        Text {
            id: titleText
            anchors.verticalCenter: parent.verticalCenter
            text: musicPanel.shell.activePlayer ? musicPanel.shell.activePlayer.trackTitle : ""
            color: musicPanel.shell.pillForeground
            font.pixelSize: 17
            font.bold: true
            font.family: musicPanel.shell.pillFont
            x: 0

            SequentialAnimation on x {
                running: musicPanel.expanded && titleText.contentWidth > titleViewport.width
                loops: Animation.Infinite
                PauseAnimation { duration: 900 }
                NumberAnimation {
                    to: -(titleText.contentWidth - titleViewport.width)
                    duration: Math.max(1800, (titleText.contentWidth - titleViewport.width) * 24)
                }
                PauseAnimation { duration: 900 }
                NumberAnimation { to: 0; duration: 260 }
            }
        }
    }

    Text {
        anchors.top: titleViewport.bottom
        anchors.topMargin: 2
        anchors.horizontalCenter: parent.horizontalCenter
        width: Math.min(parent.width - 80, 400)
        text: musicPanel.shell.activePlayer ? musicPanel.shell.activePlayer.trackArtist : ""
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
        color: "#a7b6b1"
        font.pixelSize: 13
        font.family: musicPanel.shell.pillFont
    }

    Row {
        anchors.top: parent.top
        anchors.topMargin: 92
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 14

        Rectangle {
            width: 32; height: 32; radius: 16
            color: previous.pressed ? "#42524e" : "#26312f"
            opacity: musicPanel.shell.activePlayer && musicPanel.shell.activePlayer.canGoPrevious ? 1 : 0.35
            Text { anchors.centerIn: parent; text: "‹"; color: musicPanel.shell.pillForeground; font.pixelSize: 25 }
            MouseArea {
                id: previous
                anchors.fill: parent
                enabled: musicPanel.shell.activePlayer && musicPanel.shell.activePlayer.canGoPrevious
                onClicked: musicPanel.shell.activePlayer.previous()
            }
        }

        Rectangle {
            width: 40; height: 40; radius: 20
            color: playPause.pressed ? "#00d7bf" : musicPanel.shell.active
            opacity: musicPanel.shell.activePlayer && musicPanel.shell.activePlayer.canTogglePlaying ? 1 : 0.35
            Text {
                anchors.centerIn: parent
                text: musicPanel.shell.activePlayer && musicPanel.shell.activePlayer.isPlaying ? "Ⅱ" : "▶"
                color: "#10201d"
                font.bold: true
                font.pixelSize: 14
            }
            MouseArea {
                id: playPause
                anchors.fill: parent
                enabled: musicPanel.shell.activePlayer && musicPanel.shell.activePlayer.canTogglePlaying
                onClicked: musicPanel.shell.activePlayer.togglePlaying()
            }
        }

        Rectangle {
            width: 32; height: 32; radius: 16
            color: next.pressed ? "#42524e" : "#26312f"
            opacity: musicPanel.shell.activePlayer && musicPanel.shell.activePlayer.canGoNext ? 1 : 0.35
            Text { anchors.centerIn: parent; text: "›"; color: musicPanel.shell.pillForeground; font.pixelSize: 25 }
            MouseArea {
                id: next
                anchors.fill: parent
                enabled: musicPanel.shell.activePlayer && musicPanel.shell.activePlayer.canGoNext
                onClicked: musicPanel.shell.activePlayer.next()
            }
        }
    }

    Item {
        visible: musicPanel.shell.activePlayer && musicPanel.shell.activePlayer.volumeSupported
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 14
        anchors.horizontalCenter: parent.horizontalCenter
        width: 190
        height: 8

        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width; height: 4; radius: 2
            color: "#42524e"
        }
        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width * Math.max(0, Math.min(1, musicPanel.shell.activePlayerVolume))
            height: 4; radius: 2
            color: musicPanel.shell.pillForeground
        }
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onPressed: function(mouse) { musicPanel.shell.setActivePlayerVolume(mouse.x / width); }
            onPositionChanged: function(mouse) {
                if (pressed)
                    musicPanel.shell.setActivePlayerVolume(mouse.x / width);
            }
        }
    }
}
