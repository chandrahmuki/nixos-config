import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland

Variants {
    id: overview
    required property var shell
    model: Quickshell.screens

        PanelWindow {
            id: overviewWindow
            required property var modelData
            screen: modelData
            anchors { top: true; bottom: true; left: true; right: true }
            exclusionMode: ExclusionMode.Ignore
            aboveWindows: true
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
            color: "transparent"
            visible: overview.shell.overviewOpen
                && Hyprland.monitorFor(modelData) === Hyprland.focusedMonitor
            onVisibleChanged: if (visible) overviewKeyboard.forceActiveFocus()

            HyprlandFocusGrab {
                windows: [overviewWindow]
                active: overviewWindow.visible
                onCleared: overview.shell.overviewOpen = false
            }

            MouseArea {
                anchors.fill: parent
                onClicked: overview.shell.overviewOpen = false
            }

            Rectangle {
                id: overviewBox
                width: Math.min(1080, parent.width - 48)
                height: Math.min(560, parent.height - 80)
                anchors.centerIn: parent
                radius: 12
                color: overview.shell.surface
                border.width: 1
                border.color: overview.shell.accent

                Item {
                    id: overviewKeyboard
                    anchors.fill: parent
                    focus: true
                    Keys.onEscapePressed: overview.shell.overviewOpen = false
                    Keys.onTabPressed: overview.shell.moveOverviewWorkspace(1)
                    Keys.onBacktabPressed: overview.shell.moveOverviewWorkspace(-1)
                    Keys.onLeftPressed: overview.shell.moveOverviewSelection(-1)
                    Keys.onRightPressed: overview.shell.moveOverviewSelection(1)
                    Keys.onUpPressed: overview.shell.moveOverviewSelection(-2)
                    Keys.onDownPressed: overview.shell.moveOverviewSelection(2)
                    Keys.onReturnPressed: overview.shell.focusOverviewSelection()
                    Keys.onEnterPressed: overview.shell.focusOverviewSelection()
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 14

                    Text {
                        Layout.fillWidth: true
                        text: "Workspaces — " + Hyprland.monitors.values.length + " écrans"
                        color: overview.shell.foreground
                        font.pixelSize: 20
                        font.bold: true
                    }

                    Text {
                        Layout.fillWidth: true
                        text: "Tab workspace · flèches fenêtre · Entrée ouvrir · Échap fermer"
                        color: overview.shell.foreground
                        opacity: 0.7
                    }

                    ListView {
                        id: workspaceSlots
                        Layout.fillWidth: true
                        Layout.preferredHeight: 52
                        clip: true
                        orientation: ListView.Horizontal
                        spacing: 8
                        model: overview.shell.overviewWorkspaces
                        currentIndex: overview.shell.overviewWorkspaceIndex
                        onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Contain)

                        delegate: Rectangle {
                            required property var modelData
                            required property int index
                            width: 170
                            height: workspaceSlots.height
                            radius: 7
                            color: overview.shell.overviewWorkspaceIndex === index
                                ? overview.shell.selection : overview.shell.background
                            border.width: overview.shell.overviewWorkspaceIndex === index ? 2 : 1
                            border.color: overview.shell.overviewWorkspaceIndex === index
                                ? overview.shell.accent : overview.shell.surface

                            Text {
                                anchors.fill: parent
                                anchors.margins: 10
                                verticalAlignment: Text.AlignVCenter
                                text: (modelData.monitor ? modelData.monitor.name : "Écran")
                                    + " · workspace " + modelData.id
                                color: overview.shell.overviewWorkspaceIndex === index
                                    ? overview.shell.accent : overview.shell.foreground
                                elide: Text.ElideRight
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    overview.shell.overviewWorkspaceIndex = index;
                                    overview.shell.overviewIndex = 0;
                                    overview.shell.focusOverviewWorkspace(modelData.id);
                                }
                            }
                        }

                        footer: Rectangle {
                            width: 52
                            height: workspaceSlots.height
                            radius: 7
                            color: overview.shell.background
                            border.width: 1
                            border.color: overview.shell.surface

                            Text { anchors.centerIn: parent; text: "+"; color: overview.shell.foreground; font.pixelSize: 22 }
                            MouseArea {
                                anchors.fill: parent
                            onClicked: {
                                const workspaceId = overview.shell.nextWorkspaceId();
                                if (workspaceId > 0)
                                    overview.shell.focusOverviewWorkspace(workspaceId);
                            }
                            }
                        }
                    }

                    GridView {
                        id: overviewGrid
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        cellWidth: width / 2
                        cellHeight: 112
                        model: overview.shell.overviewToplevels
                        currentIndex: overview.shell.overviewIndex
                        onCurrentIndexChanged: positionViewAtIndex(currentIndex, GridView.Contain)
                        ScrollBar.vertical: ScrollBar {
                            policy: ScrollBar.AsNeeded
                        }

                        delegate: Item {
                            required property var modelData
                            required property int index
                            width: overviewGrid.cellWidth
                            height: overviewGrid.cellHeight

                            Rectangle {
                                anchors.fill: parent
                                anchors.margins: 5
                                radius: 8
                                color: overview.shell.overviewIndex === index
                                    ? overview.shell.selection : overview.shell.background
                                border.width: overview.shell.overviewIndex === index ? 2 : 1
                                border.color: overview.shell.overviewIndex === index
                                    ? overview.shell.accent : overview.shell.surface

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 14
                                    spacing: 12

                                    Image {
                                        source: overview.shell.iconFor(modelData)
                                        sourceSize.width: 32
                                        sourceSize.height: 32
                                        Layout.preferredWidth: 32
                                        Layout.preferredHeight: 32
                                        visible: source.toString().length > 0
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 4

                                        Text {
                                            Layout.fillWidth: true
                                            text: modelData.title || "Sans titre"
                                            elide: Text.ElideRight
                                            color: overview.shell.overviewIndex === index
                                                ? overview.shell.accent : overview.shell.foreground
                                            font.pixelSize: 16
                                            font.bold: true
                                        }

                                        Text {
                                            Layout.fillWidth: true
                                            text: modelData.lastIpcObject.class || "Application"
                                            elide: Text.ElideRight
                                            color: overview.shell.foreground
                                            opacity: 0.7
                                        }
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onEntered: overview.shell.overviewIndex = index
                                    onClicked: {
                                        overview.shell.overviewIndex = index;
                                        overview.shell.focusOverviewToplevel(modelData);
                                    }
                                }
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            visible: overview.shell.overviewToplevels.length === 0
                            text: "Aucune fenêtre dans ce workspace"
                            color: overview.shell.foreground
                            opacity: 0.7
                        }
                    }
                }
            }
        }
    }
