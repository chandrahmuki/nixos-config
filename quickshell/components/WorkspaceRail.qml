import QtQuick
import Quickshell.Hyprland

Item {
    id: workspaceRail
    required property var shell
    required property var monitor
    readonly property int cellWidth: 30
    readonly property var slots: [1, 2, 3, 4, 5]
    readonly property int activeWorkspaceIndex: {
        return workspaceRail.monitor && workspaceRail.monitor.activeWorkspace
            ? workspaceRail.shell.localWorkspaceLabel(workspaceRail.monitor.activeWorkspace.id) - 1 : -1;
    }
    implicitWidth: workspaceCells.implicitWidth + 8
    implicitHeight: 26

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: "#151515"
        border.width: 1
        border.color: "#303030"
    }

    Rectangle {
        id: activeWorkspaceSegment
        visible: workspaceRail.activeWorkspaceIndex >= 0
        x: 2 + workspaceRail.activeWorkspaceIndex * workspaceRail.cellWidth
        y: 3
        width: workspaceRail.cellWidth + 4
        height: parent.height - 6
        radius: height / 2
        color: workspaceRail.shell.pillActive

        Behavior on x {
            NumberAnimation {
                duration: 180
                easing.type: Easing.OutCubic
            }
        }
    }

    Row {
        id: workspaceCells
        anchors.centerIn: parent
        spacing: 0

        Repeater {
            model: workspaceRail.slots
            delegate: Item {
                required property int modelData
                readonly property int workspaceId: workspaceRail.shell.workspaceIdForLocalSlot(
                    modelData, workspaceRail.monitor ? workspaceRail.monitor.name : "")
                readonly property bool active: modelData - 1
                    === workspaceRail.activeWorkspaceIndex
                readonly property bool occupied: Hyprland.toplevels.values.some(function(toplevel) {
                    return toplevel.workspace && toplevel.workspace.id === workspaceId;
                })
                width: workspaceRail.cellWidth
                height: workspaceRail.height

                Text {
                    anchors.centerIn: parent
                    text: modelData
                    color: active ? workspaceRail.shell.pillBackground
                        : occupied ? workspaceRail.shell.pillForeground : "#6d6d6d"
                    font.family: workspaceRail.shell.pillFont
                    font.pixelSize: active || occupied ? 15 : 11
                    font.bold: occupied
                    style: active ? Text.Outline : Text.Normal
                    styleColor: color
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (!workspaceRail.monitor)
                            return;
                        workspaceRail.shell.focusWorkspaceOnMonitor(
                            workspaceRail.shell.workspaceIdForLocalSlot(
                                modelData, workspaceRail.monitor.name),
                            workspaceRail.monitor.name);
                    }
                }
            }
        }
    }
}
