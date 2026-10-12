import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland

// Cheat sheet of the shortcuts in daily use: Hyprland (files/hyprland/hyprland.lua)
// and the Preonic keymap (qmk/.../keymap.c). The lists below are written by hand,
// so they must be updated together with those two files.
Variants {
    id: shortcuts
    required property var shell
    model: Quickshell.screens

    readonly property var columns: [
        {
            title: "FENÊTRES",
            rows: [
                { keys: ["Super", "T"], label: "Terminal" },
                { keys: ["Super", "B"], label: "Fichiers (Thunar)" },
                { keys: ["Super", "D"], label: "Lanceur" },
                { keys: ["Super", "O"], label: "Aperçu des espaces" },
                { keys: ["Super", "Q"], label: "Fermer la fenêtre" },
                { keys: ["Super", "F"], label: "Plein écran" },
                { keys: ["Super", "Espace"], label: "Maximiser" },
                { keys: ["Super", "V"], label: "Flottante / tuilée" },
                { keys: ["Super", "L"], label: "Verrouiller" },
                { keys: ["Super", "Retour"], label: "Alimentation" },
                { keys: ["Super", "Shift", "T"], label: "Thèmes" },
                { keys: ["Super", "H"], label: "Ce panneau" }
            ]
        },
        {
            title: "ESPACES ET OUTILS",
            rows: [
                { keys: ["Super", "1…9"], label: "Aller à l'espace" },
                { keys: ["Super", "Shift", "1…9"], label: "Envoyer la fenêtre" },
                { keys: ["Super", "← ↑ → ↓"], label: "Changer de focus" },
                { keys: ["Super", "Molette"], label: "Focus gauche / droite" },
                { keys: ["Super", "Shift", "Molette"], label: "Changer d'espace" },
                { keys: ["Super", "Clic gauche"], label: "Déplacer" },
                { keys: ["Super", "Clic droit"], label: "Redimensionner" },
                { keys: ["Super", "S"], label: "Terminal flottant" },
                { keys: ["Super", "I"], label: "IRC (WeeChat)" },
                { keys: ["Super", "Shift", "S"], label: "Capture d'écran" },
                { keys: ["Super", "R"], label: "Enregistrer l'écran" },
                { keys: ["Super", "Shift", "R"], label: "Stop enregistrement" },
                { keys: ["F1"], label: "Dictée" }
            ]
        },
        {
            title: "CLAVIER PREONIC",
            rows: [
                { keys: ["A", "S", "D", "F"], label: "Tenu : Super Alt Ctrl Shift" },
                { keys: ["J", "K", "L", ";"], label: "Tenu : Shift Ctrl Alt Super" },
                { keys: ["/"], label: "Tenu : accents (é, à, ç…)" },
                { keys: ["/", "Shift"], label: "Accent en majuscule" },
                { keys: ["Lower"], label: "F1–F12, médias, Pg↑ Pg↓ Fin" },
                { keys: ["Lower", "Ctrl"], label: "Verrouillage majuscules" },
                { keys: ["Raise"], label: "Chiffres, F1–F12, - = [ ] \\" },
                { keys: ["Lower", "Raise"], label: "Lumière, réglages" },
                { keys: ["Lower", "Raise", "Q"], label: "Mode flash du clavier" },
                { keys: ["Bas gauche"], label: "Lumière on / off" },
                { keys: ["Entrée"], label: "Tap : Entrée · Tenu : Shift" }
            ]
        }
    ]

    PanelWindow {
        id: shortcutsWindow
        required property var modelData
        screen: modelData
        anchors { top: true; bottom: true; left: true; right: true }
        exclusionMode: ExclusionMode.Ignore
        aboveWindows: true
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "muggynix-shortcuts"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
        color: "transparent"
        // Everything below is sized relative to the screen: 1 at 1280x800, up to 1.6.
        readonly property real k: Math.max(1, Math.min(1.6, Math.min(width / 1280, height / 800)))
        visible: shortcuts.shell.shortcutsOpen
            && Hyprland.monitorFor(modelData) === Hyprland.focusedMonitor
        onVisibleChanged: if (visible) keyboard.forceActiveFocus()

        HyprlandFocusGrab {
            windows: [shortcutsWindow]
            active: shortcutsWindow.visible
            onCleared: shortcuts.shell.closeShortcuts()
        }

        Rectangle {
            anchors.fill: parent
            color: shortcuts.shell.background
            opacity: 0.82
        }

        MouseArea {
            anchors.fill: parent
            onClicked: shortcuts.shell.closeShortcuts()
        }

        Item {
            id: keyboard
            anchors.fill: parent
            focus: true
            Keys.onEscapePressed: shortcuts.shell.closeShortcuts()

            Rectangle {
                id: card
                anchors.centerIn: parent
                width: Math.min(1320 * shortcutsWindow.k, parent.width - 48)
                height: Math.min(content.implicitHeight + 64 * shortcutsWindow.k, parent.height - 48)
                radius: 18 * shortcutsWindow.k
                color: shortcuts.shell.surface
                border.width: 1
                border.color: shortcuts.shell.borderStrong

                // Keeps a click on the card from reaching the veil behind it.
                MouseArea { anchors.fill: parent }

                RowLayout {
                    id: content
                    anchors.fill: parent
                    anchors.margins: 32 * shortcutsWindow.k
                    spacing: 36 * shortcutsWindow.k

                    Repeater {
                        model: shortcuts.columns

                        delegate: ColumnLayout {
                            id: column
                            required property var modelData
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignTop
                            spacing: 9 * shortcutsWindow.k

                            Text {
                                text: column.modelData.title
                                color: shortcuts.shell.accent
                                font.family: shortcuts.shell.pillFont
                                font.pixelSize: 18 * shortcutsWindow.k
                                font.bold: true
                                font.letterSpacing: 2 * shortcutsWindow.k
                                Layout.bottomMargin: 6 * shortcutsWindow.k
                            }

                            Repeater {
                                model: column.modelData.rows

                                delegate: RowLayout {
                                    id: row
                                    required property var modelData
                                    spacing: 10 * shortcutsWindow.k
                                    Layout.fillWidth: true

                                    Row {
                                        Layout.preferredWidth: 184 * shortcutsWindow.k
                                        Layout.alignment: Qt.AlignTop
                                        spacing: 3 * shortcutsWindow.k

                                        Repeater {
                                            model: row.modelData.keys

                                            delegate: Rectangle {
                                                id: chip
                                                required property string modelData
                                                width: chipText.implicitWidth + 12 * shortcutsWindow.k
                                                height: 30 * shortcutsWindow.k
                                                radius: 6 * shortcutsWindow.k
                                                color: shortcuts.shell.surfaceHover
                                                border.width: 1
                                                border.color: shortcuts.shell.borderMuted

                                                Text {
                                                    id: chipText
                                                    anchors.centerIn: parent
                                                    text: chip.modelData
                                                    color: shortcuts.shell.pillForeground
                                                    font.family: shortcuts.shell.pillFont
                                                    font.pixelSize: 15 * shortcutsWindow.k
                                                }
                                            }
                                        }
                                    }

                                    Text {
                                        Layout.fillWidth: true
                                        Layout.alignment: Qt.AlignTop
                                        Layout.topMargin: 5 * shortcutsWindow.k
                                        text: row.modelData.label
                                        color: shortcuts.shell.foreground
                                        font.family: shortcuts.shell.pillFont
                                        font.pixelSize: 16 * shortcutsWindow.k
                                        wrapMode: Text.WordWrap
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
