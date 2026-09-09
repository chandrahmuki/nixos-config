import QtQuick
import QtQuick.Layouts

Rectangle {
    id: musicPanel
    required property var shell
    property bool expanded: false
    readonly property bool playing: shell.activePlayer && shell.activePlayer.isPlaying
    readonly property bool volumeAvailable: shell.activePlayer && shell.activePlayer.volumeSupported
    readonly property real playerLevel: volumeAvailable ? shell.activePlayerVolume : 0

    visible: opacity > 0
    y: 0
    opacity: expanded ? 1 : 0
    scale: expanded ? 1 : 0.96
    transformOrigin: Item.Center
    radius: 14
    clip: true
    color: shell.pillBackground

    Behavior on opacity { NumberAnimation { duration: 180 } }
    Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

    function openPanel(): void { closeTimer.stop(); expanded = true; }
    function scheduleClose(): void { closeTimer.restart(); }
    function closePanel(): void { closeTimer.stop(); expanded = false; }

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
        onHoveredChanged: hovered ? closeTimer.stop() : musicPanel.scheduleClose()
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 5

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 15
            spacing: 6
            Rectangle {
                width: 5; height: 5; radius: 3
                color: musicPanel.playing ? musicPanel.shell.retroCyan : musicPanel.shell.retroAmber
                SequentialAnimation on opacity {
                    running: musicPanel.expanded && musicPanel.playing
                    loops: Animation.Infinite
                    NumberAnimation { to: 0.3; duration: 600 }
                    NumberAnimation { to: 1; duration: 600 }
                }
            }
            Text { text: "NOW PLAYING"; color: musicPanel.shell.pillForeground; font.family: musicPanel.shell.pillFont; font.pixelSize: 12; font.bold: true }
            Item { Layout.fillWidth: true }
            Text { text: musicPanel.playing ? "TAPE // RUN" : "TAPE // HOLD"; color: musicPanel.playing ? musicPanel.shell.retroCyan : musicPanel.shell.retroAmber; font.family: musicPanel.shell.pillFont; font.pixelSize: 9 }
        }

        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: musicPanel.shell.panelLine }

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 76
            spacing: 9

            // Compact input meter, retained from the pill's CAVA signal.
            Column {
                Layout.preferredWidth: 38
                Layout.fillHeight: true
                spacing: 3
                Text { anchors.horizontalCenter: parent.horizontalCenter; text: "SIG"; color: musicPanel.shell.retroCyan; font.family: musicPanel.shell.pillFont; font.pixelSize: 8 }
                Item {
                    width: parent.width; height: 46
                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        spacing: 3
                        Repeater {
                            model: 4
                            delegate: Rectangle {
                                required property int index
                                width: 4
                                height: musicPanel.playing ? 5 + musicPanel.shell.cavaLevels[index] * 0.18 : 5
                                anchors.bottom: parent.bottom
                                radius: 1
                                color: musicPanel.shell.retroCyan
                                Behavior on height { NumberAnimation { duration: 45 } }
                            }
                        }
                    }
                }
                Text { anchors.horizontalCenter: parent.horizontalCenter; text: "LIVE"; color: "#a7b6b1"; font.family: musicPanel.shell.pillFont; font.pixelSize: 8 }
            }

            Rectangle { Layout.fillHeight: true; Layout.preferredWidth: 1; color: musicPanel.shell.panelLine }

            // Cassette hero: rotating reel teeth make the player feel alive
            // without requiring artwork or a texture asset.
            Rectangle {
                Layout.preferredWidth: 188
                Layout.fillHeight: true
                radius: 4
                color: "#111716"
                border.width: 1
                border.color: musicPanel.shell.panelLine

                Text {
                    anchors.top: parent.top
                    anchors.topMargin: 5
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "TYPE I  //  SIDE A"
                    color: musicPanel.shell.retroCyan
                    font.family: musicPanel.shell.pillFont
                    font.pixelSize: 8
                }
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - 26
                    height: 36
                    radius: 3
                    color: "#202827"
                    border.width: 1
                    border.color: "#354640"
                }
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    width: 38
                    height: 4
                    radius: 2
                    color: "#0e1211"
                }

                Repeater {
                    model: [0, 1]
                    delegate: Item {
                        required property int index
                        width: 38; height: 38
                        x: index === 0 ? 24 : parent.width - width - 24
                        anchors.verticalCenter: parent.verticalCenter
                        rotation: 0
                        SequentialAnimation on rotation {
                            running: musicPanel.expanded && musicPanel.playing
                            loops: Animation.Infinite
                            NumberAnimation { from: 0; to: index === 0 ? -360 : 360; duration: index === 0 ? 2400 : 1850 }
                        }
                        Rectangle { anchors.fill: parent; radius: width / 2; color: "#111716"; border.width: 3; border.color: index === 0 ? musicPanel.shell.retroCyan : musicPanel.shell.retroAmber }
                        Repeater {
                            model: 6
                            delegate: Rectangle {
                                required property int index
                                width: 3; height: 9; radius: 1
                                color: "#4b5a55"
                                x: parent.width / 2 - width / 2
                                y: 3
                                transform: Rotation { origin.x: 1.5; origin.y: 16; angle: index * 60 }
                            }
                        }
                        Rectangle { anchors.centerIn: parent; width: 10; height: 10; radius: 5; color: "#050706"; border.width: 1; border.color: "#62736c" }
                    }
                }
                Text {
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 5
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: musicPanel.playing ? "▸  00:00" : "Ⅱ  PAUSED"
                    color: musicPanel.playing ? musicPanel.shell.retroAmber : "#a7b6b1"
                    font.family: musicPanel.shell.pillFont
                    font.pixelSize: 8
                }
            }

            Rectangle { Layout.fillHeight: true; Layout.preferredWidth: 1; color: musicPanel.shell.panelLine }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 3
                Text { text: "TRACK"; color: musicPanel.shell.retroCyan; font.family: musicPanel.shell.pillFont; font.pixelSize: 8 }
                Text { Layout.fillWidth: true; text: musicPanel.shell.activePlayer ? musicPanel.shell.activePlayer.trackTitle : "NO ACTIVE PLAYER"; elide: Text.ElideRight; color: musicPanel.shell.pillForeground; font.family: musicPanel.shell.pillFont; font.pixelSize: 14; font.bold: true }
                Text { Layout.fillWidth: true; text: musicPanel.shell.activePlayer ? musicPanel.shell.activePlayer.trackArtist : "Start a player to link it here"; elide: Text.ElideRight; color: "#a7b6b1"; font.family: musicPanel.shell.pillFont; font.pixelSize: 10 }
                Item { Layout.fillHeight: true }
                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 14
                    spacing: 4
                    Text { text: "PLAYER"; color: musicPanel.shell.retroAmber; font.family: musicPanel.shell.pillFont; font.pixelSize: 8 }
                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Row {
                            anchors.centerIn: parent
                            spacing: 3
                            Repeater {
                                model: 5
                                delegate: Rectangle {
                                    required property int index
                                    readonly property real level: (index + 1) / 5
                                    width: 6
                                    height: 5 + index * 2
                                    anchors.bottom: parent.bottom
                                    radius: 1
                                    color: musicPanel.playerLevel >= level ? musicPanel.shell.retroAmber : musicPanel.shell.panelLine
                                    MouseArea {
                                        anchors.fill: parent
                                        enabled: musicPanel.volumeAvailable
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: musicPanel.shell.setActivePlayerVolume(parent.level)
                                    }
                                }
                            }
                        }
                    }
                    Text { text: musicPanel.volumeAvailable ? Math.round(musicPanel.playerLevel * 100) + "%" : "--"; color: musicPanel.shell.pillForeground; font.family: musicPanel.shell.pillFont; font.pixelSize: 8 }
                }
            }
        }

        // The lower edge is part of the cassette machine, not a loose button
        // row. Its transport cluster is aligned under the cassette bay.
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 31
            radius: 3
            color: "#111716"
            border.width: 1
            border.color: musicPanel.shell.panelLine

            Rectangle { anchors.left: parent.left; anchors.leftMargin: 8; anchors.verticalCenter: parent.verticalCenter; width: 34; height: 2; radius: 1; color: "#354640" }
            Rectangle { anchors.right: parent.right; anchors.rightMargin: 8; anchors.verticalCenter: parent.verticalCenter; width: 34; height: 2; radius: 1; color: "#354640" }
            Rectangle { anchors.left: parent.left; anchors.leftMargin: 4; anchors.top: parent.top; anchors.topMargin: 4; width: 3; height: 3; radius: 2; color: "#61716a" }
            Rectangle { anchors.right: parent.right; anchors.rightMargin: 4; anchors.bottom: parent.bottom; anchors.bottomMargin: 4; width: 3; height: 3; radius: 2; color: "#61716a" }

            Item {
                // Main row: signal (38) + two gaps/divider (19) precedes the
                // 188px cassette bay, so this puts the transport at its center.
                x: 57
                width: 188
                height: parent.height

                Row {
                    anchors.centerIn: parent
                    spacing: 6
                    Rectangle {
                        width: 33; height: 25; radius: 3
                        color: previous.pressed ? "#42524e" : musicPanel.shell.panelSurface
                        border.width: 1; border.color: musicPanel.shell.panelLine
                        opacity: musicPanel.shell.activePlayer && musicPanel.shell.activePlayer.canGoPrevious ? 1 : 0.35
                        Text { anchors.centerIn: parent; text: "‹‹"; color: musicPanel.shell.pillForeground; font.pixelSize: 13; font.bold: true }
                        MouseArea { id: previous; anchors.fill: parent; enabled: musicPanel.shell.activePlayer && musicPanel.shell.activePlayer.canGoPrevious; onClicked: musicPanel.shell.activePlayer.previous() }
                    }
                    Rectangle {
                        width: 92; height: 25; radius: 3
                        color: playPause.pressed ? "#d99d49" : musicPanel.shell.retroAmber
                        opacity: musicPanel.shell.activePlayer && musicPanel.shell.activePlayer.canTogglePlaying ? 1 : 0.35
                        Text { anchors.centerIn: parent; text: musicPanel.playing ? "Ⅱ  PAUSE" : "▶  PLAY"; color: "#10201d"; font.family: musicPanel.shell.pillFont; font.pixelSize: 10; font.bold: true }
                        MouseArea { id: playPause; anchors.fill: parent; enabled: musicPanel.shell.activePlayer && musicPanel.shell.activePlayer.canTogglePlaying; onClicked: musicPanel.shell.activePlayer.togglePlaying() }
                    }
                    Rectangle {
                        width: 33; height: 25; radius: 3
                        color: next.pressed ? "#42524e" : musicPanel.shell.panelSurface
                        border.width: 1; border.color: musicPanel.shell.panelLine
                        opacity: musicPanel.shell.activePlayer && musicPanel.shell.activePlayer.canGoNext ? 1 : 0.35
                        Text { anchors.centerIn: parent; text: "››"; color: musicPanel.shell.pillForeground; font.pixelSize: 13; font.bold: true }
                        MouseArea { id: next; anchors.fill: parent; enabled: musicPanel.shell.activePlayer && musicPanel.shell.activePlayer.canGoNext; onClicked: musicPanel.shell.activePlayer.next() }
                    }
                }
            }
        }
    }
}
