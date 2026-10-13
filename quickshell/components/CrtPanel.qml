import QtQuick

// The base of the panels that unfold from the pill: a terminal-style frame with a
// "> TITLE ........ status" line, a body area (the children), scanlines, and the open /
// close behaviour that all of them share.
Rectangle {
    id: panel
    required property var shell
    property string title: ""
    property string status: ""
    property color statusColor: shell.theme.panelDim
    property bool expanded: false
    default property alias content: body.data

    visible: opacity > 0
    y: 0
    opacity: expanded ? 1 : 0
    scale: expanded ? 1 : 0.96
    transformOrigin: Item.Center
    radius: 6
    clip: true
    color: shell.theme.pillBackground

    Behavior on opacity { NumberAnimation { duration: 180 } }
    Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

    function openPanel(): void {
        closeTimer.stop();
        expanded = true;
    }

    function closePanel(): void {
        closeTimer.stop();
        expanded = false;
    }

    function scheduleClose(): void {
        closeTimer.restart();
    }

    Timer {
        id: closeTimer
        interval: 300
        repeat: false
        onTriggered: {
            if (!panelHover.hovered)
                panel.expanded = false;
        }
    }

    HoverHandler {
        id: panelHover
        enabled: panel.expanded
        onHoveredChanged: {
            if (hovered)
                closeTimer.stop();
            else
                panel.scheduleClose();
        }
    }

    // Double frame.
    Rectangle {
        anchors.fill: parent
        anchors.margins: 3
        color: "transparent"
        border.width: 2
        border.color: panel.shell.theme.panelDim
    }
    Rectangle {
        anchors.fill: parent
        anchors.margins: 8
        color: "transparent"
        border.width: 1
        border.color: panel.shell.theme.panelFaint
    }

    Row {
        id: header
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.leftMargin: 20
        anchors.rightMargin: 20
        anchors.topMargin: 15
        height: 18
        spacing: 8

        Text {
            id: titleText
            text: "> " + panel.title
            color: panel.shell.theme.retroCyan
            font.family: panel.shell.theme.pillFont
            font.pixelSize: 13
            font.bold: true
            font.letterSpacing: 1.5
        }
        CrtDots {
            y: parent.height - 6
            width: header.width - titleText.width - statusText.width - header.spacing * 2
            color: panel.shell.theme.panelFaint
        }
        Text {
            id: statusText
            text: panel.status
            color: panel.statusColor
            font.family: panel.shell.theme.pillFont
            font.pixelSize: 12
            font.bold: true
            font.letterSpacing: 1.5
        }
    }

    Item {
        id: body
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: header.bottom
        anchors.bottom: parent.bottom
        anchors.leftMargin: 20
        anchors.rightMargin: 20
        anchors.topMargin: 14
        anchors.bottomMargin: 18
    }

    // Scanlines over everything.
    Item {
        anchors.fill: parent
        enabled: false
        Repeater {
            model: Math.ceil(panel.height / 4)
            delegate: Rectangle {
                required property int index
                y: index * 4
                width: panel.width
                height: 1
                color: "black"
                opacity: 0.18
            }
        }
    }
}
