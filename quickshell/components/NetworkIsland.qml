import QtQuick
import QtQuick.Layouts

Rectangle {
    id: networkPanel
    required property var shell
    property bool expanded: false
    readonly property bool online: shell.networkConnectionName.length > 0

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

    function openPanel(): void {
        closeTimer.stop();
        expanded = true;
    }

    function closePanel(): void {
        closeTimer.stop();
        expanded = false;
    }

    function togglePanel(): void {
        if (expanded)
            closePanel();
        else
            openPanel();
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
                networkPanel.expanded = false;
        }
    }

    HoverHandler {
        id: panelHover
        enabled: networkPanel.expanded
        onHoveredChanged: {
            if (hovered)
                closeTimer.stop();
            else
                networkPanel.scheduleClose();
        }
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
                color: networkPanel.online ? networkPanel.shell.retroCyan : networkPanel.shell.retroCoral
                SequentialAnimation on opacity {
                    running: networkPanel.expanded && networkPanel.online
                    loops: Animation.Infinite
                    NumberAnimation { to: 0.35; duration: 600 }
                    NumberAnimation { to: 1; duration: 600 }
                }
            }
            Text {
                text: networkPanel.shell.networkType === "wifi" ? "WI-FI / LINKED"
                    : networkPanel.shell.networkType === "ethernet" ? "ETHERNET / LINKED" : "NETWORK / OFFLINE"
                color: networkPanel.shell.pillForeground
                font.family: networkPanel.shell.pillFont
                font.pixelSize: 12
                font.bold: true
            }
            Item { Layout.fillWidth: true }
            Text {
                text: networkPanel.online ? "LIVE LINK" : "NO CARRIER"
                color: networkPanel.online ? networkPanel.shell.retroCyan : networkPanel.shell.retroCoral
                font.family: networkPanel.shell.pillFont
                font.pixelSize: 9
            }
        }

        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: networkPanel.shell.panelLine }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 10

            Column {
                Layout.preferredWidth: 135
                Layout.fillHeight: true
                spacing: 3
                Text {
                    text: networkPanel.shell.networkType === "ethernet" ? "󰈀"
                        : networkPanel.shell.networkType === "wifi" ? "󰖩" : "󰤭"
                    color: networkPanel.online ? networkPanel.shell.retroAmber : networkPanel.shell.retroCoral
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 28
                }
                Text {
                    width: parent.width
                    text: networkPanel.online ? networkPanel.shell.networkConnectionName : "DISCONNECTED"
                    elide: Text.ElideRight
                    color: networkPanel.shell.pillForeground
                    font.family: networkPanel.shell.pillFont
                    font.pixelSize: 12
                    font.bold: true
                }
                Text {
                    text: networkPanel.shell.networkDevice || "NO DEVICE"
                    color: networkPanel.shell.retroAmber
                    font.family: networkPanel.shell.pillFont
                    font.pixelSize: 9
                }
            }

            Rectangle { Layout.fillHeight: true; Layout.preferredWidth: 1; color: networkPanel.shell.panelLine }

            Column {
                Layout.preferredWidth: 102
                Layout.fillHeight: true
                spacing: 6
                Repeater {
                    model: [
                        ["↓ DOWN", networkPanel.shell.rateLabel(networkPanel.shell.downloadRate), networkPanel.shell.retroCyan],
                        ["↑ UP", networkPanel.shell.rateLabel(networkPanel.shell.uploadRate), networkPanel.shell.retroCoral]
                    ]
                    delegate: Column {
                        required property var modelData
                        width: parent.width
                        spacing: 1
                        Text { text: modelData[0]; color: modelData[2]; font.family: networkPanel.shell.pillFont; font.pixelSize: 9 }
                        Text { text: modelData[1]; color: networkPanel.shell.pillForeground; font.family: networkPanel.shell.pillFont; font.pixelSize: 12; font.bold: true }
                    }
                }
            }

            Rectangle { Layout.fillHeight: true; Layout.preferredWidth: 1; color: networkPanel.shell.panelLine }

            Column {
                Layout.preferredWidth: 74
                Layout.fillHeight: true
                spacing: 7
                Repeater {
                    model: [
                        ["ADDR", networkPanel.shell.networkAddress],
                        ["GW", networkPanel.shell.networkGateway]
                    ]
                    delegate: Column {
                        required property var modelData
                        width: parent.width
                        spacing: 1
                        Text { text: modelData[0]; color: networkPanel.shell.retroAmber; font.family: networkPanel.shell.pillFont; font.pixelSize: 8 }
                        Text { width: parent.width; text: modelData[1]; elide: Text.ElideRight; color: networkPanel.shell.pillForeground; font.family: networkPanel.shell.pillFont; font.pixelSize: 9 }
                    }
                }
            }

            Rectangle { Layout.fillHeight: true; Layout.preferredWidth: 1; color: networkPanel.shell.panelLine }

            Column {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 7
                Repeater {
                    model: [
                        ["RX", networkPanel.shell.downloadHistory, networkPanel.shell.retroCyan],
                        ["TX", networkPanel.shell.uploadHistory, networkPanel.shell.retroCoral]
                    ]
                    delegate: Column {
                        id: graphRow
                        required property var modelData
                        readonly property var graphSpec: modelData
                        readonly property color graphColor: graphSpec[2]
                        width: parent.width
                        spacing: 2
                        Text { text: modelData[0]; color: graphRow.graphColor; font.family: networkPanel.shell.pillFont; font.pixelSize: 8 }
                        Row {
                            width: parent.width
                            height: 20
                            spacing: 2
                            Repeater {
                                model: graphRow.graphSpec[1]
                                delegate: Rectangle {
                                    required property var modelData
                                    readonly property real level: Number(modelData) || 0
                                    width: 3
                                    height: 3 + level * 17
                                    anchors.bottom: parent.bottom
                                    radius: 1
                                    color: networkPanel.online ? graphRow.graphColor : networkPanel.shell.panelLine
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
