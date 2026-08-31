import QtQuick

Item {
    id: networkControl
    required property var shell
    // Hyprland.monitorFor() can be null for one frame during hot reload.
    property var monitor: null
    width: networkHover.hovered ? 148 : 24
    height: 24

    Behavior on width {
        NumberAnimation { duration: 160; easing.type: Easing.OutCubic }
    }

    HoverHandler {
        id: networkHover
        onHoveredChanged: {
            if (hovered)
                networkControl.shell.scheduleNetworkAppOpen(
                    networkControl.monitor ? networkControl.monitor.name : "");
            else
                networkControl.shell.scheduleNetworkAppClose();
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: networkHover.hovered ? "#202020" : "transparent"
    }

    Text {
        anchors.left: parent.left
        anchors.leftMargin: 4
        anchors.verticalCenter: parent.verticalCenter
        text: networkControl.shell.networkType === "ethernet" ? "󰈀"
            : networkControl.shell.networkType === "wifi" ? "󰖩" : "󰤭"
        color: networkControl.shell.networkConnectionName.length > 0
            ? networkControl.shell.pillForeground : "#777777"
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 19
    }

    Text {
        visible: networkHover.hovered
        anchors.left: parent.left
        anchors.leftMargin: 28
        anchors.right: parent.right
        anchors.rightMargin: 9
        anchors.verticalCenter: parent.verticalCenter
        text: networkControl.shell.networkConnectionName.length > 0
            ? networkControl.shell.networkConnectionName : "Hors ligne"
        elide: Text.ElideRight
        color: networkControl.shell.pillForeground
        font.family: networkControl.shell.pillFont
        font.pixelSize: 11
    }

}
