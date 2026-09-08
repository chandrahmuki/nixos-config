import QtQuick
import QtQuick.Controls
import QtQuick.Effects
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
            // Omarchy-style: an opaque near-black menu, not a translucent card.
            color: "#18191d"
            border.width: 1
            border.color: "#41cfc0"
            clip: true

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 13
                spacing: 6

                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 32

                    TextField {
                        id: launcherInput
                        anchors.left: parent.left
                        anchors.leftMargin: 0
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        height: parent.height
                        background: Rectangle { color: "#111217"; radius: 2 }
                        placeholderText: "Go..."
                        placeholderTextColor: "#8da09a"
                        color: launcher.shell.pillForeground
                        font.family: launcher.shell.pillFont
                        font.pixelSize: 18
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
                        height: 36

                        Rectangle {
                            anchors.fill: parent
                            color: "transparent"

                            IconImage {
                                id: fallbackIcon
                                anchors.left: parent.left
                                anchors.leftMargin: 7
                                anchors.verticalCenter: parent.verticalCenter
                                width: 23
                                height: 23
                                source: Quickshell.iconPath(modelData.icon, "")
                                visible: false
                            }

                            MultiEffect {
                                anchors.fill: fallbackIcon
                                source: fallbackIcon
                                colorization: 1.0
                                colorizationColor: launcher.shell.pillForeground
                                visible: themedIcon.status !== Image.Ready
                            }

                            // The launcher uses the same Catppuccin monochrome theme as the
                            // pill/tray.  The effect above only covers application IDs the
                            // theme does not ship yet.
                            Image {
                                id: themedIcon
                                anchors.centerIn: fallbackIcon
                                width: fallbackIcon.width
                                height: fallbackIcon.height
                                source: "file:///home/david/.local/share/icons/catppuccin-mono-light/apps/scalable/"
                                    + modelData.icon + ".svg"
                                fillMode: Image.PreserveAspectFit
                            }

                            Text {
                                anchors.left: parent.left
                                anchors.leftMargin: 35
                                anchors.right: parent.right
                                anchors.rightMargin: 8
                                anchors.verticalCenter: parent.verticalCenter
                                text: modelData.name
                                elide: Text.ElideRight
                                color: launcher.shell.selectedIndex === index
                                    ? launcher.shell.active : launcher.shell.pillForeground
                                font.family: launcher.shell.pillFont
                                font.pixelSize: 17
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
