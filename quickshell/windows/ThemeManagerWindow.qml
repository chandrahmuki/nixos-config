import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland

Variants {
    id: themeManager
    required property var shell
    model: Quickshell.screens

    PanelWindow {
        id: themeWindow
        required property var modelData
        screen: modelData
        anchors { top: true; bottom: true; left: true; right: true }
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        color: "transparent"
        visible: themeManager.shell.themeManagerOpen
            && Hyprland.monitorFor(modelData) === Hyprland.focusedMonitor
        property int selectedThemeIndex: 0
        readonly property var selectedTheme: themeManager.shell.themeProfiles[selectedThemeIndex]
        onVisibleChanged: {
            if (!visible)
                return;
            selectedThemeIndex = Math.max(0, themeManager.shell.themeProfiles.findIndex(function(theme) {
                return theme.id === themeManager.shell.activeThemeId;
            }));
            themeFocus.forceActiveFocus();
        }

        HyprlandFocusGrab {
            windows: [themeWindow]
            active: themeWindow.visible
            onCleared: themeManager.shell.themeManagerOpen = false
        }

        Rectangle { anchors.fill: parent; color: "#000000"; opacity: 0.62 }
        MouseArea { anchors.fill: parent; onClicked: themeManager.shell.themeManagerOpen = false }

        Rectangle {
            id: panel
            width: Math.min(820, parent.width - 64)
            height: 460
            anchors.centerIn: parent
            color: themeManager.shell.pillBackground
            border.width: 2
            border.color: themeManager.shell.retroCyan
            radius: 5
            clip: true

            Rectangle {
                anchors.fill: parent
                anchors.margins: 7
                color: themeManager.shell.panelSurface
                border.width: 1
                border.color: themeManager.shell.panelLine
                radius: 2

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 18
                    spacing: 14

                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: "THEME DECK"; color: themeManager.shell.pillForeground; font.family: themeManager.shell.pillFont; font.pixelSize: 23; font.bold: true }
                        Item { Layout.fillWidth: true }
                        Text { text: "QUICKSHELL // LIVE"; color: themeManager.shell.retroCyan; font.family: themeManager.shell.pillFont; font.pixelSize: 10; font.bold: true }
                    }

                    Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: themeManager.shell.panelLine }
                    Text {
                        Layout.fillWidth: true
                        text: "← → pour choisir, Entrée pour appliquer. L'aperçu reste ouvert après application."
                        color: themeManager.shell.muted
                        font.family: themeManager.shell.pillFont
                        font.pixelSize: 11
                        wrapMode: Text.WordWrap
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 12

                        Repeater {
                            model: themeManager.shell.themeProfiles
                            delegate: Rectangle {
                                required property var modelData
                                required property int index
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                color: modelData.background
                                border.width: themeWindow.selectedThemeIndex === index ? 3 : 1
                                border.color: themeWindow.selectedThemeIndex === index ? modelData.accent : modelData.muted
                                radius: 4

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 14
                                    spacing: 9
                                    Text { text: modelData.name; color: modelData.foreground; font.family: themeManager.shell.pillFont; font.pixelSize: 13; font.bold: true }
                                    Text { Layout.fillWidth: true; text: modelData.description; color: modelData.foreground; opacity: 0.72; font.family: themeManager.shell.pillFont; font.pixelSize: 10; wrapMode: Text.WordWrap }
                                    Item { Layout.fillHeight: true }
                                    Row {
                                        spacing: 5
                                        Repeater {
                                            model: [modelData.background, modelData.surface, modelData.accent, modelData.active, modelData.retroAmber]
                                            delegate: Rectangle { required property var modelData; width: 23; height: 23; radius: 2; color: modelData; border.width: 1; border.color: "#ffffff"; opacity: 0.9 }
                                        }
                                    }
                                    Text { text: themeManager.shell.activeThemeId === modelData.id ? "ACTIF" : ""; color: modelData.active; font.family: themeManager.shell.pillFont; font.pixelSize: 10; font.bold: true }
                                }
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: themeWindow.selectedThemeIndex = index }
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: "ESC pour fermer"; color: themeManager.shell.retroAmber; font.family: themeManager.shell.pillFont; font.pixelSize: 9 }
                        Item { Layout.fillWidth: true }
                        Rectangle {
                            Layout.preferredWidth: 190
                            Layout.preferredHeight: 34
                            color: themeWindow.selectedTheme.active
                            border.width: 1
                            border.color: themeWindow.selectedTheme.accent
                            radius: 2
                            Text { anchors.centerIn: parent; text: "APPLIQUER " + themeWindow.selectedTheme.name; color: themeWindow.selectedTheme.background; font.family: themeManager.shell.pillFont; font.pixelSize: 10; font.bold: true }
                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: themeManager.shell.applyShellTheme(themeWindow.selectedTheme.id) }
                        }
                    }
                }
            }
        }

        Item {
            id: themeFocus
            focus: true
            Keys.onEscapePressed: themeManager.shell.themeManagerOpen = false
            Keys.onLeftPressed: themeWindow.selectedThemeIndex = Math.max(0, themeWindow.selectedThemeIndex - 1)
            Keys.onRightPressed: themeWindow.selectedThemeIndex = Math.min(themeManager.shell.themeProfiles.length - 1, themeWindow.selectedThemeIndex + 1)
            Keys.onReturnPressed: themeManager.shell.applyShellTheme(themeWindow.selectedTheme.id)
            Keys.onEnterPressed: themeManager.shell.applyShellTheme(themeWindow.selectedTheme.id)
        }
    }
}
