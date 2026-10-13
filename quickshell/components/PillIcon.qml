import QtQuick

Item {
    id: pillIcon
    required property var shell
    required property string glyph
    property bool hovered: false
    property color iconColor: shell.theme.retroCyan
    width: 22
    height: 24

    Rectangle {
        anchors.fill: parent
        radius: 4
        color: pillIcon.hovered ? pillIcon.shell.theme.surfaceHover : pillIcon.shell.theme.pillActive
        Behavior on color { ColorAnimation { duration: 120 } }
    }

    Text {
        anchors.centerIn: parent
        text: pillIcon.glyph
        color: pillIcon.iconColor
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 17
    }
}
