import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland

Variants {
    id: launcher
    required property var shell
    model: Quickshell.screens

    PanelWindow {
        id: launcherWindow
        required property var modelData
        screen: modelData
        anchors { top: true; bottom: true; left: true; right: true }
        exclusionMode: ExclusionMode.Ignore
        color: "transparent"
        visible: launcher.shell.launcherOpen
            && Hyprland.monitorFor(modelData) === Hyprland.focusedMonitor
        onVisibleChanged: if (visible) launcherInput.forceActiveFocus()

        HyprlandFocusGrab {
            windows: [launcherWindow]
            active: launcherWindow.visible
            onCleared: launcher.shell.launcherOpen = false
        }

        MouseArea {
            anchors.fill: parent
            onClicked: launcher.shell.launcherOpen = false
        }

        Rectangle {
            width: launcher.shell.launcherWidth
            height: launcher.shell.launcherHeight
            anchors.centerIn: parent
            radius: 12
            color: launcher.shell.surface
            border.width: 1
            border.color: launcher.shell.accent

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 10

                TextField {
                    id: launcherInput
                    Layout.fillWidth: true
                    placeholderText: "Rechercher une application…"
                    placeholderTextColor: launcher.shell.foreground
                    color: launcher.shell.foreground
                    focus: true
                    selectByMouse: true
                    text: launcher.shell.searchText

                    background: Rectangle {
                        radius: 6
                        color: launcher.shell.background
                        border.width: 1
                        border.color: launcher.shell.accent
                    }

                    onTextChanged: {
                        launcher.shell.searchText = text;
                        launcher.shell.selectedIndex = 0;
                    }
                    Keys.onEscapePressed: launcher.shell.launcherOpen = false
                    Keys.onUpPressed: launcher.shell.moveSelection(-1)
                    Keys.onDownPressed: launcher.shell.moveSelection(1)
                    Keys.onReturnPressed: launcher.shell.launchSelection()
                    Keys.onEnterPressed: launcher.shell.launchSelection()
                }

                ListView {
                    id: launcherList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    model: launcher.shell.matchingApplications
                    currentIndex: launcher.shell.selectedIndex
                    spacing: 4
                    onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Contain)

                    delegate: Item {
                        required property var modelData
                        required property int index
                        width: launcherList.width
                        height: 42

                        Rectangle {
                            anchors.fill: parent
                            radius: 6
                            color: launcher.shell.selectedIndex === index
                                ? launcher.shell.selection : "transparent"

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.leftMargin: 12
                                width: parent.width - 24
                                elide: Text.ElideRight
                                text: modelData.name
                                color: launcher.shell.selectedIndex === index
                                    ? launcher.shell.accent : launcher.shell.foreground
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onEntered: launcher.shell.selectedIndex = index
                                onClicked: {
                                    launcher.shell.selectedIndex = index;
                                    launcher.shell.launchSelection();
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
