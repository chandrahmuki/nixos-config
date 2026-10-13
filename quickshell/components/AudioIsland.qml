import QtQuick
import QtQuick.Layouts

CrtPanel {
    id: audioPanel
    readonly property real outputLevel: shell.audio.muted ? 0 : shell.audio.volume

    title: "SYSTEM AUDIO"
    status: shell.audio.muted ? "MUTED" : "MASTER OUTPUT"
    statusColor: shell.audio.muted ? shell.theme.retroCoral : shell.theme.panelDim

    RowLayout {
        anchors.fill: parent
        spacing: 16

        // Master volume.
        ColumnLayout {
            Layout.preferredWidth: 116
            Layout.fillHeight: true
            spacing: 6

            Item { Layout.fillHeight: true }
            PixelIcon {
                size: 32
                name: audioPanel.shell.audio.muted ? "volume-muted" : "volume"
                color: audioPanel.shell.audio.muted
                    ? audioPanel.shell.theme.retroCoral : audioPanel.shell.theme.retroCyan
            }
            Text {
                text: "MASTER"
                color: audioPanel.shell.theme.panelDim
                font.family: audioPanel.shell.theme.pillFont
                font.pixelSize: 11
                font.bold: true
                font.letterSpacing: 2
            }
            Text {
                text: audioPanel.shell.audio.muted ? "MUTED" : Math.round(audioPanel.shell.audio.volume * 100) + "%"
                color: audioPanel.shell.audio.muted
                    ? audioPanel.shell.theme.retroCoral : audioPanel.shell.theme.retroCyan
                font.family: audioPanel.shell.theme.pillFont
                font.pixelSize: audioPanel.shell.audio.muted ? 24 : 40
                font.bold: true
            }
            Item { Layout.fillHeight: true }
        }

        // Five levels to click, and the output they act on.
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 8

            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 8

                Repeater {
                    model: 5
                    delegate: Rectangle {
                        required property int index
                        readonly property real level: (index + 1) / 5
                        readonly property bool lit: audioPanel.outputLevel >= level
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: lit ? audioPanel.shell.theme.retroCyan : "transparent"
                        border.width: 2
                        border.color: lit ? audioPanel.shell.theme.retroCyan : audioPanel.shell.theme.panelFaint

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 10
                            text: Math.round(parent.level * 100)
                            color: parent.lit ? audioPanel.shell.theme.pillBackground : audioPanel.shell.theme.panelDim
                            font.family: audioPanel.shell.theme.pillFont
                            font.pixelSize: 15
                            font.bold: true
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: audioPanel.shell.audio.setVolume(parent.level)
                        }
                    }
                }
            }

            RowLayout {
                spacing: 6
                Text {
                    text: "> PIPEWIRE / DEFAULT SINK"
                    color: audioPanel.shell.theme.panelDim
                    font.family: audioPanel.shell.theme.pillFont
                    font.pixelSize: 11
                    font.bold: true
                    font.letterSpacing: 1.5
                }
                // Blinking terminal cursor.
                Rectangle {
                    width: 7
                    height: 11
                    color: audioPanel.shell.theme.retroCyan
                    SequentialAnimation on opacity {
                        running: audioPanel.expanded
                        loops: Animation.Infinite
                        NumberAnimation { to: 0; duration: 500 }
                        NumberAnimation { to: 1; duration: 500 }
                    }
                }
            }
        }
    }
}
