import QtQuick
import QtQuick.Layouts
import Quickshell

Item {
    id: headset
    required property var shell
    property var device: null
    property bool panelOpen: false

    visible: device && device.connected
    width: visible ? 24 : 0
    height: 24
    readonly property bool musicPlaying: shell.activePlayer && shell.activePlayer.isPlaying

    Timer {
        id: closeTimer
        interval: 220
        repeat: false
        onTriggered: headset.panelOpen = false
    }

    Timer {
        id: openTimer
        interval: 180
        repeat: false
        onTriggered: {
            if (headsetHover.hovered)
                headset.keepPanelOpen();
        }
    }

    function keepPanelOpen(): void {
        closeTimer.stop();
        openTimer.stop();
        panelOpen = true;
    }

    function scheduleOpen(): void {
        closeTimer.stop();
        openTimer.restart();
    }

    function scheduleClose(): void {
        openTimer.stop();
        closeTimer.restart();
    }

    HoverHandler {
        id: headsetHover
        onHoveredChanged: hovered ? headset.scheduleOpen() : headset.scheduleClose()
    }

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: headsetHover.hovered ? "#202020" : "transparent"

        Item {
            anchors.centerIn: parent
            width: 24
            height: 24

            Rectangle {
                id: headsetRing
                anchors.centerIn: parent
                width: 20
                height: 20
                radius: 10
                color: "transparent"
                border.width: 1
                border.color: headset.shell.pillForeground
                opacity: headset.musicPlaying ? 0.85 : 0.5

                SequentialAnimation on scale {
                    running: headset.musicPlaying
                    loops: Animation.Infinite
                    NumberAnimation { to: 1.12; duration: 650; easing.type: Easing.OutQuad }
                    NumberAnimation { to: 1; duration: 650; easing.type: Easing.InQuad }
                }
            }

            Text {
                anchors.centerIn: parent
                text: "󰋋"
                color: headset.shell.pillForeground
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 15
            }

            Text {
                id: noteOne
                visible: headset.musicPlaying
                text: "♪"
                x: 16
                y: 0
                color: headset.shell.pillForeground
                font.family: headset.shell.pillFont
                font.pixelSize: 10

                SequentialAnimation on y {
                    running: headset.musicPlaying
                    loops: Animation.Infinite
                    NumberAnimation { to: -5; duration: 600; easing.type: Easing.OutQuad }
                    NumberAnimation { to: 0; duration: 600; easing.type: Easing.InQuad }
                }
                SequentialAnimation on opacity {
                    running: headset.musicPlaying
                    loops: Animation.Infinite
                    NumberAnimation { to: 0.25; duration: 600 }
                    NumberAnimation { to: 1; duration: 600 }
                }
            }

            Text {
                id: noteTwo
                visible: headset.musicPlaying
                text: "·"
                x: 4
                y: 17
                color: "#bdbdbd"
                font.family: headset.shell.pillFont
                font.pixelSize: 12

                SequentialAnimation on opacity {
                    running: headset.musicPlaying
                    loops: Animation.Infinite
                    PauseAnimation { duration: 380 }
                    NumberAnimation { to: 0.2; duration: 480 }
                    NumberAnimation { to: 0.9; duration: 480 }
                }
            }
        }
    }

    PopupWindow {
        id: headsetPopup
        visible: headset.panelOpen && headset.visible
        implicitWidth: 248
        implicitHeight: 180
        anchor {
            item: headset
            edges: Edges.Bottom | Edges.Left
            gravity: Edges.Bottom | Edges.Right
            rect.x: headset.width / 2 - headsetPopup.width / 2
            margins.top: 12
        }
        color: "transparent"

        Rectangle {
            anchors.fill: parent
            radius: 12
            color: "#111111"
            border.width: 1
            border.color: "#d8d8d8"

            HoverHandler {
                onHoveredChanged: hovered ? headset.keepPanelOpen() : headset.scheduleClose()
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 9

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 9

                    Text {
                        text: "󰋋"
                        color: headset.shell.pillForeground
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 24
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 1
                        Text {
                            Layout.fillWidth: true
                            text: headset.device ? headset.device.name : "Bluetooth audio"
                            elide: Text.ElideRight
                            color: headset.shell.pillForeground
                            font.family: headset.shell.pillFont
                            font.pixelSize: 16
                            font.bold: true
                        }
                        Text {
                            text: "CONNECTED  ·  AUDIO READY"
                            color: "#a7a7a7"
                            font.family: headset.shell.pillFont
                            font.pixelSize: 11
                            font.bold: true
                        }
                    }
                    Text {
                        text: "×"
                        color: "#a7a7a7"
                        font.pixelSize: 18
                    }
                }

                Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: "#3f3f3f" }

                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: "BATTERY"
                        color: "#bdbdbd"
                        font.family: headset.shell.pillFont
                        font.pixelSize: 12
                        font.bold: true
                    }
                    Item { Layout.fillWidth: true }

                    Item {
                        Layout.preferredWidth: 42
                        Layout.preferredHeight: 18

                        Rectangle {
                            width: 37
                            height: 18
                            radius: 3
                            border.width: 1
                            border.color: "#d8d8d8"
                            color: "transparent"

                            Rectangle {
                                anchors.left: parent.left
                                anchors.leftMargin: 3
                                anchors.verticalCenter: parent.verticalCenter
                                width: Math.max(0, (parent.width - 6) * (headset.device
                                    && headset.device.batteryAvailable
                                    ? Math.max(0, Math.min(1, headset.device.battery)) : 0))
                                height: parent.height - 6
                                radius: 1.5
                                color: headset.shell.pillForeground
                            }
                        }

                        Rectangle {
                            anchors.left: parent.left
                            anchors.leftMargin: 37
                            anchors.verticalCenter: parent.verticalCenter
                            width: 4
                            height: 8
                            radius: 1
                            color: "#d8d8d8"
                        }
                    }

                    Text {
                        text: headset.device && headset.device.batteryAvailable
                            ? Math.round(headset.device.battery * 100) + "%" : "—"
                        color: headset.shell.pillForeground
                        font.family: headset.shell.pillFont
                        font.pixelSize: 18
                        font.bold: true
                    }
                }

                Text {
                    Layout.fillWidth: true
                    text: headset.device ? headset.device.address : ""
                    color: "#777777"
                    font.family: headset.shell.pillFont
                    font.pixelSize: 11
                }
            }
        }
    }
}
