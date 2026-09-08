import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland

Variants {
    id: networkPanel
    required property var shell
    model: Quickshell.screens

        PanelWindow {
            id: networkAppWindow
            required property var modelData
            readonly property var hyprMonitor: Hyprland.monitorFor(modelData)
            screen: modelData
            anchors { top: true; left: true }
            implicitWidth: 400
            implicitHeight: 390
            margins {
                top: 60
                left: (modelData.width - networkAppWindow.implicitWidth) / 2
            }
            exclusionMode: ExclusionMode.Ignore
            aboveWindows: true
            WlrLayershell.layer: WlrLayer.Overlay
            focusable: false
            color: "transparent"
            visible: networkPanel.shell.networkAppOpen && networkAppWindow.hyprMonitor
                && networkAppWindow.hyprMonitor.name === networkPanel.shell.networkPanelMonitorName

            Rectangle {
                anchors.fill: parent
                radius: 18
                color: "#0c0c0c"
                border.width: 1
                border.color: "#555555"

                HoverHandler {
                    onHoveredChanged: {
                        if (hovered)
                            networkPanel.shell.keepNetworkAppOpen();
                        else
                            networkPanel.shell.scheduleNetworkAppClose();
                    }
                }

                RowLayout {
                    anchors.centerIn: parent
                    width: parent.width - 32
                    height: parent.height - 32
                    spacing: 12

                    Column {
                        Layout.preferredWidth: 58
                        Layout.alignment: Qt.AlignVCenter
                        spacing: 20

                        Repeater {
                            model: ["LINK", "NET", "DNS"]
                            delegate: Column {
                                required property var modelData
                                width: 58
                                spacing: 6
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: modelData
                                    color: "#d7d7d7"
                                    font.family: networkPanel.shell.pillFont
                                    font.pixelSize: 16
                                }
                                Rectangle {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    width: 18; height: 18; radius: 9
                                    color: "#eeeeee"
                                    border.width: 3
                                    border.color: "#363636"
                                }
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: "OK"
                                    color: "#a6a6a6"
                                    font.family: networkPanel.shell.pillFont
                                    font.pixelSize: 14
                                }
                            }
                        }
                    }

                    Rectangle { Layout.fillHeight: true; Layout.preferredWidth: 1; color: "#4b4b4b" }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: parent.height
                        spacing: 6

                        RowLayout {
                            Layout.fillWidth: true
                            Text {
                                text: networkPanel.shell.networkType === "ethernet" ? "ETHERNET / ONLINE" : "NETWORK / OFFLINE"
                                color: networkPanel.shell.pillForeground
                                font.family: networkPanel.shell.pillFont
                                font.pixelSize: 22
                                font.bold: true
                            }
                            Item { Layout.fillWidth: true }
                            Text {
                                text: "×"
                                color: "#bdbdbd"
                                font.family: networkPanel.shell.pillFont
                                font.pixelSize: 26
                                MouseArea { anchors.fill: parent; onClicked: networkPanel.shell.networkAppOpen = false }
                            }
                        }

                        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: "#555555" }

                        GridLayout {
                            Layout.fillWidth: true
                            columns: 2
                            columnSpacing: 12
                            rowSpacing: 5
                            Repeater {
                                model: [
                                    ["CONNECTION", networkPanel.shell.networkConnectionName || "—"],
                                    ["DEVICE", networkPanel.shell.networkDevice || "—"],
                                    ["LOCAL IP", networkPanel.shell.networkAddress],
                                    ["GATEWAY", networkPanel.shell.networkGateway],
                                    ["DNS", networkPanel.shell.networkDns]
                                ]
                                delegate: Item {
                                    required property var modelData
                                    Layout.columnSpan: 2
                                    Layout.fillWidth: true
                                    implicitHeight: 23
                                    Text { text: modelData[0]; color: "#9d9d9d"; font.family: networkPanel.shell.pillFont; font.pixelSize: 15 }
                                    Text { anchors.right: parent.right; text: modelData[1]; color: networkPanel.shell.pillForeground; font.family: networkPanel.shell.pillFont; font.pixelSize: 16 }
                                }
                            }
                        }

                        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: "#555555" }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4
                            Text { text: "↓ DOWN  " + networkPanel.shell.rateLabel(networkPanel.shell.downloadRate); color: networkPanel.shell.pillForeground; font.family: networkPanel.shell.pillFont; font.pixelSize: 16 }
                            Row {
                                Layout.fillWidth: true
                                height: 42
                                spacing: 3
                                Repeater {
                                    model: networkPanel.shell.downloadHistory
                                    delegate: Rectangle {
                                        required property var modelData
                                        width: 11; height: 5 + modelData * 37
                                        anchors.bottom: parent.bottom
                                        color: "#e8e8e8"
                                    }
                                }
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4
                            Text { text: "↑ UP    " + networkPanel.shell.rateLabel(networkPanel.shell.uploadRate); color: networkPanel.shell.pillForeground; font.family: networkPanel.shell.pillFont; font.pixelSize: 16 }
                            Row {
                                Layout.fillWidth: true
                                height: 42
                                spacing: 3
                                Repeater {
                                    model: networkPanel.shell.uploadHistory
                                    delegate: Rectangle {
                                        required property var modelData
                                        width: 11; height: 5 + modelData * 37
                                        anchors.bottom: parent.bottom
                                        color: "#bdbdbd"
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
