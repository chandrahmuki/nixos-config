import QtQuick
import QtQuick.Layouts

CrtPanel {
    id: musicPanel
    readonly property bool playing: shell.music.player && shell.music.player.isPlaying
    readonly property bool volumeAvailable: shell.music.player && shell.music.player.volumeSupported
    readonly property real playerLevel: volumeAvailable ? shell.music.volume : 0

    title: "NOW PLAYING"
    status: playing ? "TAPE // RUN" : "TAPE // HOLD"
    statusColor: playing ? shell.theme.retroCyan : shell.theme.panelDim

    RowLayout {
        anchors.fill: parent
        spacing: 16

        // The CAVA signal of the pill, larger.
        ColumnLayout {
            Layout.preferredWidth: 88
            Layout.fillHeight: true
            spacing: 8

            Item { Layout.fillHeight: true }
            Row {
                Layout.alignment: Qt.AlignHCenter
                spacing: 6
                Repeater {
                    model: 4
                    delegate: Item {
                        required property int index
                        width: 9
                        height: 48

                        Rectangle {
                            anchors.bottom: parent.bottom
                            width: parent.width
                            height: musicPanel.playing ? 5 + musicPanel.shell.music.cavaLevels[index] * 0.43 : 5
                            color: musicPanel.shell.theme.retroCyan
                            Behavior on height { NumberAnimation { duration: 45 } }
                        }
                    }
                }
            }
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "SIG // LIVE"
                color: musicPanel.shell.theme.panelDim
                font.family: musicPanel.shell.theme.pillFont
                font.pixelSize: 11
                font.bold: true
                font.letterSpacing: 1.5
            }
            Item { Layout.fillHeight: true }
        }

        // The track.
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 5

            Text {
                text: "TRACK"
                color: musicPanel.shell.theme.panelDim
                font.family: musicPanel.shell.theme.pillFont
                font.pixelSize: 11
                font.bold: true
                font.letterSpacing: 2
            }
            Text {
                Layout.fillWidth: true
                text: musicPanel.shell.music.player ? musicPanel.shell.music.player.trackTitle : "NO ACTIVE PLAYER"
                elide: Text.ElideRight
                color: musicPanel.shell.theme.retroCyan
                font.family: musicPanel.shell.theme.pillFont
                font.pixelSize: 19
                font.bold: true
            }
            Text {
                Layout.fillWidth: true
                text: musicPanel.shell.music.player ? musicPanel.shell.music.player.trackArtist : "Start a player to link it here"
                elide: Text.ElideRight
                color: musicPanel.shell.theme.panelDim
                font.family: musicPanel.shell.theme.pillFont
                font.pixelSize: 13
                font.bold: true
            }
            Item { Layout.fillHeight: true }
            Text {
                text: musicPanel.shell.music.player
                    ? (musicPanel.playing ? "> PLAYING" : "> PAUSED") : "> IDLE"
                color: musicPanel.shell.theme.panelDim
                font.family: musicPanel.shell.theme.pillFont
                font.pixelSize: 11
                font.bold: true
                font.letterSpacing: 1.5
            }
        }

        // Transport and player volume.
        ColumnLayout {
            Layout.preferredWidth: 152
            Layout.fillHeight: true
            spacing: 8

            RowLayout {
                spacing: 8

                Rectangle {
                    Layout.preferredWidth: 32
                    Layout.preferredHeight: 30
                    color: previous.pressed ? musicPanel.shell.theme.panelFaint : "transparent"
                    border.width: 2
                    border.color: musicPanel.shell.theme.panelDim
                    opacity: musicPanel.shell.music.player && musicPanel.shell.music.player.canGoPrevious ? 1 : 0.35
                    Text {
                        anchors.centerIn: parent
                        text: "<<"
                        color: musicPanel.shell.theme.retroCyan
                        font.family: musicPanel.shell.theme.pillFont
                        font.pixelSize: 14
                        font.bold: true
                    }
                    MouseArea {
                        id: previous
                        anchors.fill: parent
                        enabled: musicPanel.shell.music.player && musicPanel.shell.music.player.canGoPrevious
                        cursorShape: Qt.PointingHandCursor
                        onClicked: musicPanel.shell.music.player.previous()
                    }
                }
                Rectangle {
                    Layout.preferredWidth: 72
                    Layout.preferredHeight: 30
                    color: playPause.pressed ? musicPanel.shell.theme.panelDim : musicPanel.shell.theme.retroCyan
                    opacity: musicPanel.shell.music.player && musicPanel.shell.music.player.canTogglePlaying ? 1 : 0.35
                    Text {
                        anchors.centerIn: parent
                        text: musicPanel.playing ? "PAUSE" : "PLAY"
                        color: musicPanel.shell.theme.pillBackground
                        font.family: musicPanel.shell.theme.pillFont
                        font.pixelSize: 14
                        font.bold: true
                        font.letterSpacing: 1
                    }
                    MouseArea {
                        id: playPause
                        anchors.fill: parent
                        enabled: musicPanel.shell.music.player && musicPanel.shell.music.player.canTogglePlaying
                        cursorShape: Qt.PointingHandCursor
                        onClicked: musicPanel.shell.music.player.togglePlaying()
                    }
                }
                Rectangle {
                    Layout.preferredWidth: 32
                    Layout.preferredHeight: 30
                    color: next.pressed ? musicPanel.shell.theme.panelFaint : "transparent"
                    border.width: 2
                    border.color: musicPanel.shell.theme.panelDim
                    opacity: musicPanel.shell.music.player && musicPanel.shell.music.player.canGoNext ? 1 : 0.35
                    Text {
                        anchors.centerIn: parent
                        text: ">>"
                        color: musicPanel.shell.theme.retroCyan
                        font.family: musicPanel.shell.theme.pillFont
                        font.pixelSize: 14
                        font.bold: true
                    }
                    MouseArea {
                        id: next
                        anchors.fill: parent
                        enabled: musicPanel.shell.music.player && musicPanel.shell.music.player.canGoNext
                        cursorShape: Qt.PointingHandCursor
                        onClicked: musicPanel.shell.music.player.next()
                    }
                }
            }

            Item { Layout.fillHeight: true }

            RowLayout {
                spacing: 8

                Text {
                    text: "VOL"
                    color: musicPanel.shell.theme.panelDim
                    font.family: musicPanel.shell.theme.pillFont
                    font.pixelSize: 11
                    font.bold: true
                    font.letterSpacing: 1.5
                }
                Row {
                    Layout.alignment: Qt.AlignBottom
                    spacing: 3
                    Repeater {
                        model: 5
                        delegate: Item {
                            required property int index
                            readonly property real level: (index + 1) / 5
                            width: 9
                            height: 20

                            Rectangle {
                                anchors.bottom: parent.bottom
                                width: parent.width
                                height: 6 + index * 3.5
                                color: musicPanel.playerLevel >= parent.level
                                    ? musicPanel.shell.theme.retroCyan : musicPanel.shell.theme.panelFaint
                            }
                            MouseArea {
                                anchors.fill: parent
                                enabled: musicPanel.volumeAvailable
                                cursorShape: Qt.PointingHandCursor
                                onClicked: musicPanel.shell.music.setVolume(parent.level)
                            }
                        }
                    }
                }
                Text {
                    text: musicPanel.volumeAvailable ? Math.round(musicPanel.playerLevel * 100) + "%" : "--"
                    color: musicPanel.shell.theme.retroCyan
                    font.family: musicPanel.shell.theme.pillFont
                    font.pixelSize: 14
                    font.bold: true
                }
            }
        }
    }
}
