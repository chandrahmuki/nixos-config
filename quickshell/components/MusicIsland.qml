import QtQuick
import QtQuick.Layouts

Rectangle {
    id: musicPanel
    required property var shell
    property bool expanded: false
    readonly property bool playing: shell.activePlayer && shell.activePlayer.isPlaying
    readonly property real systemOutputLevel: shell.systemMuted ? 0 : shell.systemVolume

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

        // Shared status-strip grammar with weather and network.
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
                    NumberAnimation { to: 0.35; duration: 600 }
                    NumberAnimation { to: 1; duration: 600 }
                }
            }
            Text {
                text: "NOW PLAYING"
                color: musicPanel.shell.pillForeground
                font.family: musicPanel.shell.pillFont
                font.pixelSize: 12
                font.bold: true
            }
            Item { Layout.fillWidth: true }
            Text {
                text: musicPanel.playing ? "LIVE SIGNAL" : "PAUSED"
                color: musicPanel.playing ? musicPanel.shell.retroCyan : musicPanel.shell.retroAmber
                font.family: musicPanel.shell.pillFont
                font.pixelSize: 9
            }
        }

        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: musicPanel.shell.panelLine }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 10

            // Bounded signal module: no floating visualizer or empty space.
            Rectangle {
                Layout.preferredWidth: 92
                Layout.fillHeight: true
                radius: 3
                color: musicPanel.shell.panelSurface
                border.width: 1
                border.color: musicPanel.shell.panelLine
                Column {
                    anchors.centerIn: parent
                    spacing: 5
                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: "SIGNAL"; color: musicPanel.shell.retroCyan; font.family: musicPanel.shell.pillFont; font.pixelSize: 8 }
                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: "󰎆"; color: musicPanel.shell.retroAmber; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 26 }
                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 4
                        Repeater {
                            model: 4
                            delegate: Rectangle {
                                required property int index
                                width: 5
                                height: musicPanel.playing ? 4 + musicPanel.shell.cavaLevels[index] * 0.16 : 4
                                anchors.verticalCenter: parent.verticalCenter
                                radius: 1
                                color: musicPanel.shell.retroCyan
                                Behavior on height { NumberAnimation { duration: 45; easing.type: Easing.OutQuad } }
                            }
                        }
                    }
                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: musicPanel.playing ? "PLAY" : "HOLD"; color: musicPanel.playing ? musicPanel.shell.retroCyan : musicPanel.shell.retroAmber; font.family: musicPanel.shell.pillFont; font.pixelSize: 8 }
                }
            }

            Rectangle { Layout.fillHeight: true; Layout.preferredWidth: 1; color: musicPanel.shell.panelLine }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 3
                Text { text: "TRACK"; color: musicPanel.shell.retroCyan; font.family: musicPanel.shell.pillFont; font.pixelSize: 8 }
                Text {
                    Layout.fillWidth: true
                    text: musicPanel.shell.activePlayer ? musicPanel.shell.activePlayer.trackTitle : "NO ACTIVE PLAYER"
                    elide: Text.ElideRight
                    color: musicPanel.shell.pillForeground
                    font.family: musicPanel.shell.pillFont
                    font.pixelSize: 16
                    font.bold: true
                }
                Text {
                    Layout.fillWidth: true
                    text: musicPanel.shell.activePlayer ? musicPanel.shell.activePlayer.trackArtist : "Start a player to link it here"
                    elide: Text.ElideRight
                    color: "#a7b6b1"
                    font.family: musicPanel.shell.pillFont
                    font.pixelSize: 11
                }
                Item { Layout.fillHeight: true }
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 5
                    Text { text: "FLOW"; color: musicPanel.shell.retroAmber; font.family: musicPanel.shell.pillFont; font.pixelSize: 8 }
                    Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 3; radius: 2; color: musicPanel.shell.panelLine }
                    Text { text: musicPanel.playing ? "RUN" : "STOP"; color: musicPanel.playing ? musicPanel.shell.retroCyan : musicPanel.shell.retroAmber; font.family: musicPanel.shell.pillFont; font.pixelSize: 8 }
                }
                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 31
                    spacing: 5
                    Rectangle {
                        Layout.preferredWidth: 31; Layout.preferredHeight: 29; radius: 3
                        color: previous.pressed ? "#42524e" : musicPanel.shell.panelSurface
                        border.width: 1; border.color: musicPanel.shell.panelLine
                        opacity: musicPanel.shell.activePlayer && musicPanel.shell.activePlayer.canGoPrevious ? 1 : 0.35
                        Text { anchors.centerIn: parent; text: "‹"; color: musicPanel.shell.pillForeground; font.pixelSize: 22 }
                        MouseArea { id: previous; anchors.fill: parent; enabled: musicPanel.shell.activePlayer && musicPanel.shell.activePlayer.canGoPrevious; onClicked: musicPanel.shell.activePlayer.previous() }
                    }
                    Rectangle {
                        Layout.fillWidth: true; Layout.preferredHeight: 29; radius: 3
                        color: playPause.pressed ? "#d99d49" : musicPanel.shell.retroAmber
                        opacity: musicPanel.shell.activePlayer && musicPanel.shell.activePlayer.canTogglePlaying ? 1 : 0.35
                        Text { anchors.centerIn: parent; text: musicPanel.playing ? "Ⅱ  PAUSE" : "▶  PLAY"; color: "#10201d"; font.family: musicPanel.shell.pillFont; font.pixelSize: 10; font.bold: true }
                        MouseArea { id: playPause; anchors.fill: parent; enabled: musicPanel.shell.activePlayer && musicPanel.shell.activePlayer.canTogglePlaying; onClicked: musicPanel.shell.activePlayer.togglePlaying() }
                    }
                    Rectangle {
                        Layout.preferredWidth: 31; Layout.preferredHeight: 29; radius: 3
                        color: next.pressed ? "#42524e" : musicPanel.shell.panelSurface
                        border.width: 1; border.color: musicPanel.shell.panelLine
                        opacity: musicPanel.shell.activePlayer && musicPanel.shell.activePlayer.canGoNext ? 1 : 0.35
                        Text { anchors.centerIn: parent; text: "›"; color: musicPanel.shell.pillForeground; font.pixelSize: 22 }
                        MouseArea { id: next; anchors.fill: parent; enabled: musicPanel.shell.activePlayer && musicPanel.shell.activePlayer.canGoNext; onClicked: musicPanel.shell.activePlayer.next() }
                    }
                }
            }

            Rectangle { Layout.fillHeight: true; Layout.preferredWidth: 1; color: musicPanel.shell.panelLine }

            Column {
                Layout.preferredWidth: 52
                Layout.fillHeight: true
                spacing: 5
                Text { text: "SYS OUT"; color: musicPanel.shell.retroCyan; font.family: musicPanel.shell.pillFont; font.pixelSize: 8 }
                Text { text: musicPanel.shell.systemMuted ? "MUTE" : Math.round(musicPanel.systemOutputLevel * 100) + "%"; color: musicPanel.shell.pillForeground; font.family: musicPanel.shell.pillFont; font.pixelSize: 14; font.bold: true }
                Item {
                    width: parent.width; height: 39
                    Row {
                        anchors.bottom: parent.bottom
                        spacing: 3
                        Repeater {
                            model: 5
                            delegate: Rectangle {
                                required property int index
                                readonly property real threshold: (index + 1) / 5
                                width: 5; height: 8 + index * 6
                                anchors.bottom: parent.bottom
                                radius: 1
                                color: musicPanel.systemOutputLevel >= threshold ? musicPanel.shell.retroAmber : musicPanel.shell.panelLine
                            }
                        }
                    }
                }
                Text { text: musicPanel.shell.systemMuted ? "MUTED" : "SYSTEM"; color: "#a7b6b1"; font.family: musicPanel.shell.pillFont; font.pixelSize: 8 }
            }
        }
    }

    // The output module owns system volume, away from the compact pill.
    MouseArea {
        x: parent.width - 72
        y: parent.height - 84
        width: 62
        height: 84
        cursorShape: Qt.PointingHandCursor
        onPressed: function(mouse) { musicPanel.shell.setSystemVolume(1 - mouse.y / height); }
        onPositionChanged: function(mouse) {
            if (pressed)
                musicPanel.shell.setSystemVolume(1 - mouse.y / height);
        }
    }
}
