import QtQuick
import QtQuick.Layouts

CrtPanel {
    id: networkPanel
    readonly property bool online: shell.network.connectionName.length > 0

    title: shell.network.type === "wifi" ? "WI-FI / LINKED"
        : shell.network.type === "ethernet" ? "ETHERNET / LINKED" : "NETWORK / OFFLINE"
    status: online ? "LIVE LINK" : "NO CARRIER"
    statusColor: online ? shell.theme.panelDim : shell.theme.retroCoral

    function togglePanel(): void {
        if (expanded)
            closePanel();
        else
            openPanel();
    }

    // Three columns placed explicitly: the connection, the listing, the history.
    Item {
        anchors.fill: parent

        ColumnLayout {
            id: connection
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: 128
            spacing: 5

            Item { Layout.fillHeight: true }
            PixelIcon {
                size: 48
                name: networkPanel.shell.network.type === "ethernet" ? "ethernet"
                    : networkPanel.shell.network.type === "wifi" ? "wifi" : "wifi-off"
                color: networkPanel.online
                    ? networkPanel.shell.theme.retroCyan : networkPanel.shell.theme.retroCoral
            }
            Text {
                Layout.fillWidth: true
                text: networkPanel.online ? networkPanel.shell.network.connectionName : "DISCONNECTED"
                elide: Text.ElideRight
                color: networkPanel.shell.theme.retroCyan
                font.family: networkPanel.shell.theme.pillFont
                font.pixelSize: 13
                font.bold: true
            }
            Text {
                text: networkPanel.shell.network.device || "NO DEVICE"
                color: networkPanel.shell.theme.panelDim
                font.family: networkPanel.shell.theme.pillFont
                font.pixelSize: 11
                font.bold: true
                font.letterSpacing: 1
            }
            Item { Layout.fillHeight: true }
        }

        ColumnLayout {
            id: listing
            anchors.left: connection.right
            anchors.leftMargin: 16
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: 158
            spacing: 0

            Repeater {
                model: [
                    ["DOWN", networkPanel.shell.network.rateLabel(networkPanel.shell.network.downloadRate), 13],
                    ["UP", networkPanel.shell.network.rateLabel(networkPanel.shell.network.uploadRate), 13],
                    ["ADDR", networkPanel.shell.network.address, 12],
                    ["GW", networkPanel.shell.network.gateway, 12]
                ]
                delegate: CrtRow {
                    required property var modelData
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    shell: networkPanel.shell
                    label: modelData[0]
                    value: modelData[1]
                    valueSize: modelData[2]
                }
            }
        }

        // Receive and transmit history: 18 samples, 3 px bars every 5 px.
        Item {
            anchors.left: listing.right
            anchors.leftMargin: 16
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            clip: true

            Rectangle {
                width: 2
                height: parent.height
                color: networkPanel.shell.theme.panelFaint
            }

            ColumnLayout {
                anchors.left: parent.left
                anchors.leftMargin: 12
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8

                Repeater {
                    model: [
                        ["RX", networkPanel.shell.network.downloadHistory, networkPanel.shell.theme.retroCyan],
                        ["TX", networkPanel.shell.network.uploadHistory, networkPanel.shell.theme.panelDim]
                    ]
                    delegate: ColumnLayout {
                        id: graphRow
                        required property var modelData
                        readonly property var graphSpec: modelData
                        readonly property color graphColor: graphSpec[2]
                        Layout.fillWidth: true
                        spacing: 3

                        Text {
                            text: graphRow.graphSpec[0]
                            color: graphRow.graphColor
                            font.family: networkPanel.shell.theme.pillFont
                            font.pixelSize: 11
                            font.bold: true
                            font.letterSpacing: 1.5
                        }
                        Row {
                            Layout.preferredHeight: 24
                            spacing: 2
                            Repeater {
                                model: graphRow.graphSpec[1]
                                delegate: Item {
                                    required property var modelData
                                    readonly property real level: Number(modelData) || 0
                                    width: 3
                                    height: 24

                                    Rectangle {
                                        anchors.bottom: parent.bottom
                                        width: parent.width
                                        height: 3 + parent.level * 21
                                        color: networkPanel.online
                                            ? graphRow.graphColor : networkPanel.shell.theme.panelFaint
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
