import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Mpris
import Quickshell.Services.SystemTray
import Quickshell.Bluetooth
import "../components"

Variants {
    id: pillRoot
    required property var shell
    model: Quickshell.screens

        PanelWindow {
            id: pillWindow
            required property var modelData
            readonly property var hyprMonitor: Hyprland.monitorFor(modelData)
            readonly property var monitorWorkspaces: pillRoot.shell.overviewWorkspaces.filter(function(workspace) {
                return workspace.monitor === pillWindow.hyprMonitor;
            })
            screen: modelData
            anchors { top: true; left: true; right: true }
            implicitHeight: 54
            // Keep the active window below the pill instead of drawing over it.
            exclusionMode: ExclusionMode.Normal
            exclusiveZone: 54
            color: "transparent"

            Timer {
                interval: 1000
                running: true
                repeat: true
                onTriggered: pillRoot.shell.now = new Date()
            }

            Rectangle {
                id: pill
                width: Math.min(baseRow.implicitWidth + 32, parent.width - 32)
                height: 40
                anchors.top: parent.top
                anchors.topMargin: 7
                // Keep the tray and clock stable while the media area grows left.
                x: (parent.width + width - (musicIsland.expanded
                    ? pillRoot.shell.musicExpandedWidth - 38 : 0)) / 2 - width
                radius: height / 2
                color: pillRoot.shell.pillBackground
                border.width: 1
                border.color: "#303030"

                RowLayout {
                    id: baseRow
                    anchors.centerIn: parent
                    spacing: 10
                    WorkspaceRail {
                        id: workspaceRail
                        shell: pillRoot.shell
                        monitor: pillWindow.hyprMonitor
                    }

                    Item {
                        id: musicSlot
                        Layout.preferredWidth: pillRoot.shell.activePlayer
                            ? (musicIsland.expanded ? pillRoot.shell.musicExpandedWidth : 38) : 0
                        Layout.preferredHeight: 26
                    }

                    Row {
                        spacing: 2

                        SystemVolumeControl {
                            shell: pillRoot.shell
                        }

                        NetworkIndicator {
                            shell: pillRoot.shell
                            monitor: pillWindow.hyprMonitor
                        }

                        BluetoothHeadset {
                            shell: pillRoot.shell
                            device: pillRoot.shell.connectedHeadset
                        }
                    }

                    TrayCapsule {
                        shell: pillRoot.shell
                    }

                    WeatherWidget {
                        shell: pillRoot.shell
                    }

                    ClockWidget {
                        shell: pillRoot.shell
                    }
                }

                MusicIsland {
                    id: musicIsland
                    shell: pillRoot.shell
                    x: baseRow.x + musicSlot.x + musicSlot.width - width
                    y: baseRow.y + musicSlot.y
                }
            }
        }
    }
