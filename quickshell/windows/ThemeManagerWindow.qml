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
        // carousel.currentIndex is the single source of truth for the
        // selection: it is both the PathView's own drag/flick state and the
        // target of keyboard nav, so nothing else may declaratively bind to
        // it (that would fight the view's internal writes on drag).
        readonly property var selectedTheme: themeManager.shell.themeProfiles[carousel.currentIndex]
        onVisibleChanged: {
            if (!visible)
                return;
            carousel.currentIndex = Math.max(0, themeManager.shell.themeProfiles.findIndex(function(theme) {
                return theme.id === themeManager.shell.activeThemeId;
            }));
            themeFocus.forceActiveFocus();
            refreshSchemePreviews();
        }

        // Live swatch per Matugen colour-scheme algorithm, recomputed for
        // whichever wallpaper is currently centred in the carousel. One
        // `preview-scheme` call per algorithm, run — costs nothing to apply
        // (no state/Kitty/GTK writes) so it's safe to fire on every
        // selection change without debouncing.
        property var schemePreviewColors: ({})
        function refreshSchemePreviews() {
            schemePreviewColors = {};
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
            width: Math.min(980, parent.width - 64)
            height: Math.min(600, parent.height - 96)
            anchors.centerIn: parent
            color: themeManager.shell.pillBackground
            border.width: 2
            border.color: themeManager.shell.retroCyan
            radius: 5
            clip: true

            // Swallow clicks anywhere on the panel so they don't fall through
            // to the backdrop MouseArea and close the window.
            MouseArea { anchors.fill: parent }

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
                    spacing: 12

                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: "THEME DECK"; color: themeManager.shell.pillForeground; font.family: themeManager.shell.pillFont; font.pixelSize: 23; font.bold: true }
                        Item { Layout.fillWidth: true }
                        Text { text: "QUICKSHELL // LIVE"; color: themeManager.shell.retroCyan; font.family: themeManager.shell.pillFont; font.pixelSize: 10; font.bold: true }
                    }

                    Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: themeManager.shell.panelLine }
                    Text {
                        Layout.fillWidth: true
                        text: "← → ou clic sur les flèches pour naviguer, Entrée pour appliquer. L'aperçu reste ouvert après application."
                        color: themeManager.shell.muted
                        font.family: themeManager.shell.pillFont
                        font.pixelSize: 11
                        wrapMode: Text.WordWrap
                    }

                    // --- Carousel -------------------------------------------------
                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        ListView {
                            id: carousel
                            anchors.fill: parent
                            orientation: ListView.Horizontal
                            model: themeManager.shell.themeProfiles
                            spacing: 18
                            // Centres the current card and snaps to it — a
                            // plain ListView is far more predictable to drive
                            // from keyboard than PathView turned out to be
                            // (its custom path attributes could leave
                            // currentIndex stuck once dragged off-centre).
                            preferredHighlightBegin: (width - 300) / 2
                            preferredHighlightEnd: (width - 300) / 2
                            highlightRangeMode: ListView.StrictlyEnforceRange
                            snapMode: ListView.SnapOneItem
                            focus: false
                            onCurrentIndexChanged: themeWindow.refreshSchemePreviews()
                            header: Item { width: (carousel.width - 300) / 2; height: 1 }
                            footer: Item { width: (carousel.width - 300) / 2; height: 1 }

                            delegate: Item {
                                id: card
                                required property var modelData
                                required property int index
                                width: 300
                                height: 300
                                // Distance from the centred item drives scale/fade — measured
                                // in actual on-screen pixels (via contentX), not logical index.
                                // Driving it from the index instead let rapid key-repeat outrun
                                // the ListView's own scroll animation: currentIndex jumps
                                // instantly on every press while the view was still gliding
                                // toward the previous one, so cards snapped straight to full
                                // scale/opacity ahead of actually reaching centre — the
                                // "flattening" effect. Tying it to real position means it can
                                // only ever be as fast as the scroll itself, in sync by
                                // construction, so no separate Behavior is needed either.
                                readonly property real viewportCenterX: card.x - carousel.contentX + card.width / 2
                                readonly property real distance: Math.abs(viewportCenterX - carousel.width / 2) / (card.width + carousel.spacing)
                                scale: Math.max(0.62, 1.0 - distance * 0.19)
                                opacity: Math.max(0.35, 1.0 - distance * 0.35)
                                z: 100 - Math.round(distance * 10)

                                Rectangle {
                                    anchors.fill: parent
                                    radius: 10
                                    clip: true
                                    color: modelData.background
                                    border.width: carousel.currentIndex === card.index ? 3 : 1
                                    border.color: carousel.currentIndex === card.index ? modelData.accent : modelData.muted

                                    Image {
                                        anchors.fill: parent
                                        source: "../assets/wallpapers/" + modelData.wallpaper
                                        fillMode: Image.PreserveAspectCrop
                                        asynchronous: true
                                        smooth: true
                                    }

                                    // Scrim so the name/description stay readable over
                                    // any wallpaper, bright or dark.
                                    Rectangle {
                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                        anchors.bottom: parent.bottom
                                        height: parent.height * 0.62
                                        gradient: Gradient {
                                            GradientStop { position: 0.0; color: "#00000000" }
                                            GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0.82) }
                                        }
                                    }

                                    Text {
                                        visible: modelData.id === themeManager.shell.activeThemeId
                                        anchors.top: parent.top
                                        anchors.right: parent.right
                                        anchors.margins: 8
                                        text: "ACTIF"
                                        color: modelData.active
                                        font.family: themeManager.shell.pillFont
                                        font.pixelSize: 10
                                        font.bold: true
                                    }

                                    ColumnLayout {
                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                        anchors.bottom: parent.bottom
                                        anchors.margins: 12
                                        spacing: 6

                                        Text { text: modelData.name; color: themeManager.shell.foreground; font.family: themeManager.shell.pillFont; font.pixelSize: 13; font.bold: true }
                                        Text { Layout.fillWidth: true; text: modelData.description; color: themeManager.shell.foreground; opacity: 0.82; font.family: themeManager.shell.pillFont; font.pixelSize: 9; wrapMode: Text.WordWrap }
                                        Row {
                                            spacing: 4
                                            Repeater {
                                                model: [modelData.background, modelData.surface, modelData.accent, modelData.active, modelData.retroAmber]
                                                delegate: Rectangle { required property var modelData; width: 15; height: 15; radius: 2; color: modelData; border.width: 1; border.color: themeManager.shell.borderStrong; opacity: 0.9 }
                                            }
                                        }
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: carousel.currentIndex = card.index
                                }
                            }
                        }

                        // Chevron nav, purely a visual/clickable affordance —
                        // keyboard arrows already drive the same currentIndex.
                        Text {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            text: "‹"
                            color: themeManager.shell.retroCyan
                            font.pixelSize: 42
                            font.bold: true
                            opacity: carousel.currentIndex > 0 ? 0.9 : 0.25
                            MouseArea {
                                anchors.fill: parent
                                anchors.margins: -12
                                cursorShape: Qt.PointingHandCursor
                                enabled: carousel.currentIndex > 0
                                onClicked: carousel.currentIndex -= 1
                            }
                        }
                        Text {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            text: "›"
                            color: themeManager.shell.retroCyan
                            font.pixelSize: 42
                            font.bold: true
                            opacity: carousel.currentIndex < themeManager.shell.themeProfiles.length - 1 ? 0.9 : 0.25
                            MouseArea {
                                anchors.fill: parent
                                anchors.margins: -12
                                cursorShape: Qt.PointingHandCursor
                                enabled: carousel.currentIndex < themeManager.shell.themeProfiles.length - 1
                                onClicked: carousel.currentIndex += 1
                            }
                        }
                    }

                    // Matugen colour-scheme algorithm picker: same wallpaper,
                    // different rules for pulling a palette out of it (see
                    // aspects/hyprland.nix preview_scheme). Swatch dot shows
                    // the actual primary colour that algorithm would produce
                    // for the theme currently centred in the carousel.
                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 8
                        Text { text: "ALGO"; color: themeManager.shell.muted; font.family: themeManager.shell.pillFont; font.pixelSize: 9 }
                        Repeater {
                            model: themeManager.shell.matugenSchemes
                            delegate: Rectangle {
                                id: schemeButton
                                required property var modelData
                                readonly property bool selected: themeManager.shell.matugenScheme === modelData.id
                                readonly property string previewColor: themeWindow.schemePreviewColors[modelData.id] || themeManager.shell.panelLine
                                Layout.preferredHeight: 24
                                Layout.preferredWidth: schemeLabel.implicitWidth + 24
                                radius: 3
                                color: themeManager.shell.panelSurface
                                border.width: selected ? 2 : 1
                                border.color: selected ? previewColor : themeManager.shell.panelLine

                                RowLayout {
                                    anchors.centerIn: parent
                                    spacing: 5
                                    Rectangle {
                                        width: 14
                                        height: 14
                                        radius: 5
                                        color: schemeButton.previewColor
                                        border.width: 1
                                        border.color: themeManager.shell.borderStrong
                                        opacity: 0.9
                                        Behavior on color { ColorAnimation { duration: 150 } }
                                    }
                                    Text {
                                        id: schemeLabel
                                        text: modelData.name
                                        color: themeManager.shell.pillForeground
                                        font.family: themeManager.shell.pillFont
                                        font.pixelSize: 9
                                        font.bold: schemeButton.selected
                                    }
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: themeManager.shell.applyMatugenScheme(schemeButton.modelData.id, themeWindow.selectedTheme.id)
                                }
                            }
                        }
                    }

                    // Position dots
                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 7
                        Repeater {
                            model: themeManager.shell.themeProfiles
                            delegate: Rectangle {
                                required property int index
                                width: carousel.currentIndex === index ? 16 : 7
                                height: 7
                                radius: 3.5
                                color: carousel.currentIndex === index ? themeManager.shell.retroCyan : themeManager.shell.panelLine
                                Behavior on width { NumberAnimation { duration: 120 } }
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: carousel.currentIndex = index }
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

            // No confirm ripple here anymore: it duplicated the full-screen
            // circular reveal (BackgroundWindow.qml). Apply now closes the
            // panel immediately so that reveal is the only animation.
        }

        Item {
            id: themeFocus
            focus: true
            Keys.onEscapePressed: themeManager.shell.themeManagerOpen = false
            Keys.onLeftPressed: carousel.currentIndex = Math.max(0, carousel.currentIndex - 1)
            Keys.onRightPressed: carousel.currentIndex = Math.min(themeManager.shell.themeProfiles.length - 1, carousel.currentIndex + 1)
            Keys.onReturnPressed: themeManager.shell.applyShellTheme(themeWindow.selectedTheme.id)
            Keys.onEnterPressed: themeManager.shell.applyShellTheme(themeWindow.selectedTheme.id)
        }
    }
}
