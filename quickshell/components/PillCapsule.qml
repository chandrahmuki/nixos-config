import QtQuick

// The rounded background that groups related items of the pill. Its children are laid
// out in a row.
Rectangle {
    id: capsule
    required property var shell
    default property alias content: row.data
    property int padding: 4
    property int spacing: 0
    implicitWidth: row.implicitWidth + padding * 2
    implicitHeight: 44
    radius: 8
    color: shell.theme.panelSurface

    Row {
        id: row
        anchors.centerIn: parent
        spacing: capsule.spacing
    }
}
