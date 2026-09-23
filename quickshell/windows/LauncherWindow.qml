import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Widgets

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
        WlrLayershell.layer: WlrLayer.Overlay
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
            radius: 4
            // Opaque card, same family as the theme manager / pill overlays
            // (pillBackground + a coloured accent border) instead of a
            // fixed Omarchy hex that didn't follow theme switches.
            color: launcher.shell.pillBackground
            border.width: 1
            border.color: launcher.shell.retroCyan
            clip: true

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 13
                spacing: 6

                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40

                    TextField {
                        id: launcherInput
                        anchors.left: parent.left
                        anchors.leftMargin: 0
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        height: parent.height
                        background: Rectangle { color: launcher.shell.panelSurface; radius: 2 }
                        placeholderText: "Go..."
                        placeholderTextColor: launcher.shell.muted
                        color: launcher.shell.pillForeground
                        font.family: launcher.shell.pillFont
                        font.pixelSize: 22
                        font.bold: true
                        focus: true
                        selectByMouse: true
                        text: launcher.shell.searchText

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
                }

                ListView {
                    id: launcherList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    model: launcher.shell.matchingApplications
                    currentIndex: launcher.shell.selectedIndex
                    spacing: 1
                    onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Contain)

                    delegate: Item {
                        required property var modelData
                        required property int index
                        width: launcherList.width
                        height: 46

                        Rectangle {
                            anchors.fill: parent
                            color: "transparent"

                            Image {
                                id: themedIcon
                                anchors.left: parent.left
                                anchors.leftMargin: 7
                                anchors.verticalCenter: parent.verticalCenter
                                width: 34
                                height: 34
                                source: modelData.icon.indexOf("file://") === 0
                                    ? modelData.icon
                                    : modelData.icon.charAt(0) === "/"
                                        ? "file://" + modelData.icon
                                        : "file:///home/david/.local/share/icons/catppuccin-mono-light/apps/scalable/"
                                            + modelData.icon + ".svg"
                                fillMode: Image.PreserveAspectFit
                            }

                            Image {
                                anchors.fill: themedIcon
                                source: "file:///home/david/.local/share/icons/catppuccin-mono-light/apps/scalable/application-default.svg"
                                fillMode: Image.PreserveAspectFit
                                visible: themedIcon.status !== Image.Ready
                            }

                            // Some desktop entries use a non-standard icon
                            // name. Keep their fallback inside the same simple
                            // Catppuccin pack instead of showing a coloured
                            // hicolor application logo.
                            Text {
                                anchors.left: parent.left
                                anchors.leftMargin: 49
                                anchors.right: parent.right
                                anchors.rightMargin: 8
                                anchors.verticalCenter: parent.verticalCenter
                                text: modelData.name
                                elide: Text.ElideRight
                                color: launcher.shell.selectedIndex === index
                                    ? launcher.shell.active : launcher.shell.pillForeground
                                font.family: launcher.shell.pillFont
                                font.pixelSize: 21
                                font.bold: true
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
