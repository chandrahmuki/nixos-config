import QtQuick
import QtQuick.Layouts

Rectangle {
    id: audioPanel
    required property var shell
    property bool expanded: false
    readonly property real outputLevel: shell.systemMuted ? 0 : shell.systemVolume

    visible: opacity > 0
    y: 0
    opacity: expanded ? 1 : 0
    scale: expanded ? 1 : 0.96
    transformOrigin: Item.Center
    radius: 14
    clip: true
    color: shell.pillBackground

    Behavior on opacity { NumberAnimation { duration: 180 } }
    Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

    function openPanel(): void { closeTimer.stop(); expanded = true; }
    function closePanel(): void { closeTimer.stop(); expanded = false; }
    function scheduleClose(): void { closeTimer.restart(); }

    Timer {
        id: closeTimer
        interval: 300
        repeat: false
        onTriggered: {
            if (!panelHover.hovered)
                audioPanel.expanded = false;
        }
    }

    HoverHandler {
        id: panelHover
        enabled: audioPanel.expanded
        onHoveredChanged: hovered ? closeTimer.stop() : audioPanel.scheduleClose()
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 5

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 15
            spacing: 6
            Rectangle { width: 5; height: 5; radius: 3; color: audioPanel.shell.systemMuted ? audioPanel.shell.retroCoral : audioPanel.shell.retroAmber }
            Text { text: "SYSTEM AUDIO"; color: audioPanel.shell.pillForeground; font.family: audioPanel.shell.pillFont; font.pixelSize: 12; font.bold: true }
            Item { Layout.fillWidth: true }
            Text { text: audioPanel.shell.systemMuted ? "MUTED" : "MASTER OUTPUT"; color: audioPanel.shell.systemMuted ? audioPanel.shell.retroCoral : audioPanel.shell.retroAmber; font.family: audioPanel.shell.pillFont; font.pixelSize: 9 }
        }

        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: audioPanel.shell.panelLine }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 12

            Rectangle {
                Layout.preferredWidth: 102
                Layout.fillHeight: true
                radius: 3
                color: audioPanel.shell.panelSurface
                border.width: 1
                border.color: audioPanel.shell.panelLine
                Column {
                    anchors.centerIn: parent
                    spacing: 4
                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: audioPanel.shell.systemMuted ? "󰖁" : "󰕾"; color: audioPanel.shell.systemMuted ? audioPanel.shell.retroCoral : audioPanel.shell.retroAmber; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 30 }
                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: "MASTER"; color: audioPanel.shell.retroCyan; font.family: audioPanel.shell.pillFont; font.pixelSize: 8 }
                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: audioPanel.shell.systemMuted ? "MUTED" : Math.round(audioPanel.outputLevel * 100) + "%"; color: audioPanel.shell.pillForeground; font.family: audioPanel.shell.pillFont; font.pixelSize: 18; font.bold: true }
                }
            }

            Rectangle { Layout.fillHeight: true; Layout.preferredWidth: 1; color: audioPanel.shell.panelLine }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 6
                Text { text: "CLICK A LEVEL"; color: audioPanel.shell.retroCyan; font.family: audioPanel.shell.pillFont; font.pixelSize: 9 }
                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 6
                    Repeater {
                        model: 5
                        delegate: Rectangle {
                            required property int index
                            readonly property real level: (index + 1) / 5
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            radius: 3
                            color: audioPanel.outputLevel >= level ? audioPanel.shell.retroAmber : audioPanel.shell.panelSurface
                            border.width: 1
                            border.color: audioPanel.outputLevel >= level ? audioPanel.shell.retroAmber : audioPanel.shell.panelLine
                            Text { anchors.centerIn: parent; text: Math.round(parent.level * 100); color: audioPanel.outputLevel >= parent.level ? "#10201d" : audioPanel.shell.pillForeground; font.family: audioPanel.shell.pillFont; font.pixelSize: 11; font.bold: true }
                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: audioPanel.shell.setSystemVolume(parent.level) }
                        }
                    }
                }
                Text { text: "PIPEWIRE / DEFAULT SINK"; color: "#a7b6b1"; font.family: audioPanel.shell.pillFont; font.pixelSize: 8 }
            }
        }
    }
}
