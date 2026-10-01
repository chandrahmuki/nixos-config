import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
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

        property string filterText: ""
        property var filteredThemes: themeManager.shell.themeProfiles
        property int selectedIndex: 0
        readonly property var selectedTheme: filteredThemes.length > 0
            ? filteredThemes[Math.min(selectedIndex, filteredThemes.length - 1)]
            : themeManager.shell.themeProfiles[0]
        property var schemePreviewColors: ({})

        onVisibleChanged: {
            if (!visible)
                return;
            filterText = "";
            themeFilter.text = "";
            rebuildThemeList();
            const activeIndex = filteredThemes.findIndex(function(theme) {
                return theme.id === themeManager.shell.activeThemeId;
            });
            selectedIndex = Math.max(0, activeIndex);
            Qt.callLater(function() { themeFilter.forceActiveFocus(); });
            refreshSchemePreviews();
        }

        function rebuildThemeList() {
            const query = filterText.trim().toLowerCase();
            filteredThemes = themeManager.shell.themeProfiles.filter(function(theme) {
                return !query
                    || theme.name.toLowerCase().indexOf(query) >= 0
                    || theme.id.toLowerCase().indexOf(query) >= 0
                    || theme.description.toLowerCase().indexOf(query) >= 0;
            });
            selectedIndex = Math.max(0, filteredThemes.findIndex(function(theme) {
                return theme.id === themeManager.shell.activeThemeId;
            }));
            refreshSchemePreviews();
        }

        function moveSelection(delta) {
            if (filteredThemes.length === 0)
                return;
            selectedIndex = (selectedIndex + delta + filteredThemes.length) % filteredThemes.length;
            themeList.positionViewAtIndex(selectedIndex, ListView.Contain);
            refreshSchemePreviews();
        }

        function applySelectedTheme() {
            if (selectedTheme)
                themeManager.shell.applyShellTheme(selectedTheme.id);
        }

        function refreshSchemePreviews() {
            schemePreviewColors = ({});
            schemePreviewProcess.running = false;
            schemePreviewProcess.pendingIndex = 0;
            schemePreviewProcess.runNext();
        }

        Process {
            id: schemePreviewProcess
            property int pendingIndex: 0
            function runNext() {
                const schemes = themeManager.shell.matugenSchemes;
                if (pendingIndex >= schemes.length || !themeWindow.selectedTheme)
                    return;
                command = ["muggy-theme", "preview-scheme", themeWindow.selectedTheme.id, schemes[pendingIndex].id];
                running = true;
            }
            stdout: SplitParser {
                onRead: data => {
                    const schemes = themeManager.shell.matugenSchemes;
                    if (schemePreviewProcess.pendingIndex >= schemes.length)
                        return;
                    const id = schemes[schemePreviewProcess.pendingIndex].id;
                    const next = Object.assign({}, themeWindow.schemePreviewColors);
                    next[id] = data.trim();
                    themeWindow.schemePreviewColors = next;
                }
            }
            onExited: function(exitCode) {
                pendingIndex += 1;
                runNext();
            }
        }

        HyprlandFocusGrab {
            windows: [themeWindow]
            active: themeWindow.visible
            onCleared: themeManager.shell.themeManagerOpen = false
        }

        Rectangle { anchors.fill: parent; color: themeManager.shell.overlayScrim; opacity: 0.62 }
        MouseArea { anchors.fill: parent; onClicked: themeManager.shell.themeManagerOpen = false }

        Rectangle {
            id: panel
            width: Math.min(880, parent.width - 48)
            height: Math.min(560, parent.height - 56)
            anchors.centerIn: parent
            color: themeManager.shell.pillBackground
            border.width: 1
            border.color: themeManager.shell.retroCyan
            radius: 6
            clip: true

            // Keep clicks inside the menu from reaching the dimmed backdrop.
            MouseArea { anchors.fill: parent }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 17
                spacing: 11

                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 30
                    Text {
                        text: "THÈMES"
                        color: themeManager.shell.pillForeground
                        font.family: themeManager.shell.pillFont
                        font.pixelSize: 20
                        font.bold: true
                    }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: themeWindow.selectedTheme ? "ACTIF · " + themeManager.shell.activeTheme.name : ""
                        color: themeManager.shell.retroCyan
                        font.family: themeManager.shell.pillFont
                        font.pixelSize: 10
                        font.bold: true
                    }
                }

                Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: themeManager.shell.panelLine }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 16

                    ColumnLayout {
                        Layout.preferredWidth: 300
                        Layout.fillHeight: true
                        spacing: 8

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 40
                            color: themeManager.shell.panelSurface
                            border.width: 1
                            border.color: themeFilter.activeFocus ? themeManager.shell.accent : themeManager.shell.panelLine
                            radius: 3

                            Text {
                                anchors.left: parent.left
                                anchors.leftMargin: 11
                                anchors.verticalCenter: parent.verticalCenter
                                text: "⌕"
                                color: themeManager.shell.muted
                                font.family: themeManager.shell.pillFont
                                font.pixelSize: 20
                            }
                            TextInput {
                                id: themeFilter
                                anchors.left: parent.left
                                anchors.leftMargin: 38
                                anchors.right: parent.right
                                anchors.rightMargin: 10
                                anchors.verticalCenter: parent.verticalCenter
                                height: parent.height - 2
                                color: themeManager.shell.pillForeground
                                selectionColor: themeManager.shell.accent
                                selectedTextColor: themeManager.shell.pillBackground
                                font.family: themeManager.shell.pillFont
                                font.pixelSize: 14
                                verticalAlignment: TextInput.AlignVCenter
                                clip: true
                                onTextChanged: {
                                    themeWindow.filterText = text;
                                    themeWindow.rebuildThemeList();
                                }
                                Keys.priority: Keys.BeforeItem
                                Keys.onPressed: function(event) {
                                    if (event.key === Qt.Key_Escape) {
                                        if (text.length > 0) {
                                            text = "";
                                        } else {
                                            themeManager.shell.themeManagerOpen = false;
                                        }
                                        event.accepted = true;
                                    } else if (event.key === Qt.Key_Up) {
                                        themeWindow.moveSelection(-1);
                                        event.accepted = true;
                                    } else if (event.key === Qt.Key_Down) {
                                        themeWindow.moveSelection(1);
                                        event.accepted = true;
                                    } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                        themeWindow.applySelectedTheme();
                                        event.accepted = true;
                                    }
                                }
                                Text {
                                    anchors.fill: parent
                                    verticalAlignment: Text.AlignVCenter
                                    text: "Rechercher un thème…"
                                    color: themeManager.shell.muted
                                    font: themeFilter.font
                                    visible: themeFilter.text.length === 0
                                    enabled: false
                                }
                            }
                        }

                        ListView {
                            id: themeList
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true
                            spacing: 3
                            model: themeWindow.filteredThemes
                            currentIndex: themeWindow.selectedIndex
                            boundsBehavior: Flickable.StopAtBounds
                            highlightRangeMode: ListView.NoHighlightRange
                            onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Contain)

                            delegate: Item {
                                required property var modelData
                                required property int index
                                width: themeList.width
                                height: 37

                                Rectangle {
                                    anchors.fill: parent
                                    color: themeWindow.selectedIndex === index ? themeManager.shell.selection : "transparent"
                                    border.width: themeWindow.selectedIndex === index ? 1 : 0
                                    border.color: themeManager.shell.panelLine
                                    radius: 3
                                }
                                Rectangle {
                                    width: 3
                                    height: parent.height - 12
                                    anchors.left: parent.left
                                    anchors.leftMargin: 6
                                    anchors.verticalCenter: parent.verticalCenter
                                    color: modelData.accent
                                    radius: 2
                                }
                                Text {
                                    anchors.left: parent.left
                                    anchors.leftMargin: 17
                                    anchors.right: activeMark.left
                                    anchors.rightMargin: 8
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: modelData.name
                                    color: themeWindow.selectedIndex === index ? themeManager.shell.foreground : themeManager.shell.pillForeground
                                    font.family: themeManager.shell.pillFont
                                    font.pixelSize: 12
                                    font.bold: themeWindow.selectedIndex === index
                                    elide: Text.ElideRight
                                }
                                Text {
                                    id: activeMark
                                    anchors.right: parent.right
                                    anchors.rightMargin: 10
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: modelData.id === themeManager.shell.activeThemeId ? "✓" : "›"
                                    color: modelData.id === themeManager.shell.activeThemeId ? modelData.active : themeManager.shell.muted
                                    font.family: themeManager.shell.pillFont
                                    font.pixelSize: 14
                                    font.bold: true
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        themeWindow.selectedIndex = index;
                                        themeWindow.applySelectedTheme();
                                    }
                                }
                            }
                        }
                    }

                    Rectangle { Layout.preferredWidth: 1; Layout.fillHeight: true; color: themeManager.shell.panelLine }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 9

                        Item {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.minimumHeight: 180
                            Rectangle {
                                anchors.fill: parent
                                color: themeWindow.selectedTheme.background
                                border.width: 1
                                border.color: themeWindow.selectedTheme.accent
                                radius: 4
                                clip: true
                                Image {
                                    anchors.fill: parent
                                    source: "../assets/wallpapers/" + themeWindow.selectedTheme.wallpaper
                                    fillMode: Image.PreserveAspectCrop
                                    asynchronous: true
                                    cache: true
                                    smooth: true
                                }
                                Rectangle {
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.bottom: parent.bottom
                                    height: 78
                                    gradient: Gradient {
                                        GradientStop { position: 0; color: "#00000000" }
                                        GradientStop { position: 1; color: "#cc000000" }
                                    }
                                }
                                Text {
                                    anchors.left: parent.left
                                    anchors.bottom: parent.bottom
                                    anchors.margins: 12
                                    text: themeWindow.selectedTheme.name
                                    color: "white"
                                    font.family: themeManager.shell.pillFont
                                    font.pixelSize: 19
                                    font.bold: true
                                }
                                Text {
                                    anchors.right: parent.right
                                    anchors.top: parent.top
                                    anchors.margins: 9
                                    text: "APERÇU"
                                    color: "white"
                                    font.family: themeManager.shell.pillFont
                                    font.pixelSize: 9
                                    font.bold: true
                                }
                            }
                        }

                        Text {
                            Layout.fillWidth: true
                            text: themeWindow.selectedTheme.description
                            color: themeManager.shell.pillForeground
                            opacity: 0.86
                            font.family: themeManager.shell.pillFont
                            font.pixelSize: 11
                            wrapMode: Text.WordWrap
                            maximumLineCount: 2
                            elide: Text.ElideRight
                        }

                        Row {
                            Layout.fillWidth: true
                            spacing: 6
                            Repeater {
                                model: [themeWindow.selectedTheme.background, themeWindow.selectedTheme.surface, themeWindow.selectedTheme.accent, themeWindow.selectedTheme.active, themeWindow.selectedTheme.retroAmber]
                                delegate: Rectangle {
                                    required property var modelData
                                    width: 22
                                    height: 18
                                    radius: 3
                                    color: modelData
                                    border.width: 1
                                    border.color: themeManager.shell.panelLine
                                }
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 5
                            Text {
                                text: "PALETTE"
                                color: themeManager.shell.muted
                                font.family: themeManager.shell.pillFont
                                font.pixelSize: 9
                                font.bold: true
                            }
                            Item { Layout.fillWidth: true }
                            Repeater {
                                model: themeManager.shell.matugenSchemes
                                delegate: Rectangle {
                                    required property var modelData
                                    readonly property bool selected: themeManager.shell.matugenScheme === modelData.id
                                    readonly property color previewColor: themeWindow.schemePreviewColors[modelData.id] || themeManager.shell.panelLine
                                    Layout.preferredWidth: schemeLabel.implicitWidth + 18
                                    Layout.preferredHeight: 24
                                    color: themeManager.shell.panelSurface
                                    border.width: selected ? 1 : 0
                                    border.color: previewColor
                                    radius: 3
                                    Row {
                                        anchors.centerIn: parent
                                        spacing: 4
                                        Rectangle {
                                            width: 8
                                            height: 8
                                            anchors.verticalCenter: parent.verticalCenter
                                            color: previewColor
                                            radius: 4
                                        }
                                        Text {
                                            id: schemeLabel
                                            text: modelData.name
                                            color: themeManager.shell.pillForeground
                                            font.family: themeManager.shell.pillFont
                                            font.pixelSize: 8
                                            font.bold: selected
                                        }
                                    }
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: themeManager.shell.applyMatugenScheme(modelData.id, themeWindow.selectedTheme.id)
                                    }
                                }
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 31
                    Text {
                        text: "↑ ↓ naviguer    Entrée appliquer    Échap fermer"
                        color: themeManager.shell.muted
                        font.family: themeManager.shell.pillFont
                        font.pixelSize: 9
                    }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: themeWindow.filteredThemes.length + " thèmes"
                        color: themeManager.shell.muted
                        font.family: themeManager.shell.pillFont
                        font.pixelSize: 9
                    }
                }
            }
        }
    }
}
