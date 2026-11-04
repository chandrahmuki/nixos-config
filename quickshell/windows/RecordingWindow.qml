import QtQuick
import Quickshell
import Quickshell.Wayland

// A small indicator on the recorded monitor while muggy-screen-record runs: blinking
// dot, elapsed time and size of the file. Hyprland hides its namespace from screen
// capture (no_screen_share in files/hyprland/hyprland.lua), so it is not in the video.
Variants {
    id: recordingWindow
    required property var shell
    model: Quickshell.screens

    PanelWindow {
        id: indicator
        required property var modelData
        screen: modelData
        anchors { top: true; right: true }
        margins { top: 12; right: 16 }
        implicitWidth: row.implicitWidth + 28
        implicitHeight: 44
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "muggynix-recording"
        focusable: false
        color: "transparent"
        visible: recordingWindow.shell.recording.active
            && recordingWindow.shell.recording.monitor === indicator.modelData.name

        Rectangle {
            anchors.fill: parent
            radius: 8
            color: recordingWindow.shell.theme.pillBackground
            border.width: 1
            border.color: recordingWindow.shell.theme.panelLine

            Row {
                id: row
                anchors.centerIn: parent
                spacing: 12

                Rectangle {
                    id: dot
                    anchors.verticalCenter: parent.verticalCenter
                    width: 10
                    height: 10
                    radius: 5
                    color: recordingWindow.shell.theme.retroCoral
                    SequentialAnimation on opacity {
                        running: indicator.visible
                        loops: Animation.Infinite
                        NumberAnimation { to: 0.25; duration: 0 }
                        PauseAnimation { duration: 500 }
                        NumberAnimation { to: 1; duration: 0 }
                        PauseAnimation { duration: 700 }
                    }
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "REC"
                    font.family: recordingWindow.shell.theme.pillFont
                    font.pixelSize: 13
                    font.bold: true
                    font.letterSpacing: 1
                    color: recordingWindow.shell.theme.retroCoral
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: recordingWindow.shell.recording.elapsedLabel
                    font.family: recordingWindow.shell.theme.pillFont
                    font.pixelSize: 13
                    color: recordingWindow.shell.theme.pillForeground
                }

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 1
                    height: 18
                    color: recordingWindow.shell.theme.panelLine
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: recordingWindow.shell.recording.sizeLabel
                    font.family: recordingWindow.shell.theme.pillFont
                    font.pixelSize: 13
                    color: recordingWindow.shell.theme.retroCyan
                }
            }
        }
    }
}
